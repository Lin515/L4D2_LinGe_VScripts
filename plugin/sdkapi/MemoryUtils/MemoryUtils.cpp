/**
 * vim: set ts=4 sw=4 tw=99 noet :
 * =============================================================================
 * SourceMod
 * Copyright (C) 2004-2011 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */
 // 修改自 sourcemod/core/logic/MemoryUtils.cpp
 // https://github.com/alliedmodders/sourcemod

#include "MemoryUtils.h"
#ifdef PLATFORM_LINUX
#include <fcntl.h>
#include <link.h>
#include <sys/mman.h>
#include <sys/stat.h>

#define PAGE_SIZE			4096
#define PAGE_ALIGN_UP(x)	((x + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1))
#endif

MemoryUtils::MemoryUtils(CreateInterfaceFn factory) :
	isAvailable(false), factory(nullptr)
{
	if (factory)
		Init(factory);
}

bool MemoryUtils::Init(CreateInterfaceFn factory)
{
	this->factory = factory;
	isAvailable = MemoryUtils::GetLibraryInfo((void *)factory, this->lib);
	return isAvailable;
}

bool MemoryUtils::IsAvailable()
{
	return isAvailable;
}

void *MemoryUtils::FindPattern(const char *pattern)
{
	if (!this->isAvailable)
		return nullptr;

	bool found;
	char *ptr, *end;
	size_t len = strlen(pattern);

	ptr = reinterpret_cast<char *>(lib.baseAddress);
	end = ptr + lib.memorySize - len;

	while (ptr < end)
	{
		found = true;
		for (register size_t i = 0; i < len; i++)
		{
			if (pattern[i] != '\x2A' && pattern[i] != ptr[i])
			{
				found = false;
				break;
			}
		}

		if (found)
			return ptr;

		ptr++;
	}

	return nullptr;
}

void *MemoryUtils::ResolveSymbol(const char *symbol)
{
	if (!this->isAvailable)
		return nullptr;

	HMODULE handle = this->lib.handle;
#ifdef WIN32
	return GetProcAddress(handle, symbol);
#elif defined PLATFORM_LINUX

#ifdef PLATFORM_X86
	typedef Elf32_Ehdr ElfHeader;
	typedef Elf32_Shdr ElfSHeader;
	typedef Elf32_Sym ElfSymbol;
#define ELF_SYM_TYPE ELF32_ST_TYPE
#else
	typedef Elf64_Ehdr ElfHeader;
	typedef Elf64_Shdr ElfSHeader;
	typedef Elf64_Sym ElfSymbol;
#define ELF_SYM_TYPE ELF64_ST_TYPE
#endif

	struct link_map *dlmap;
	struct stat dlstat;
	int dlfile;
	uintptr_t map_base;
	ElfHeader *file_hdr;
	ElfSHeader *sections, *shstrtab_hdr, *symtab_hdr, *strtab_hdr;
	ElfSymbol *symtab;
	const char *shstrtab, *strtab;
	uint16_t section_count;
	uint32_t symbol_count;
	SymbolTable *table;
	Symbol *symbol_entry;

	dlmap = (struct link_map *)handle;
	symtab_hdr = nullptr;
	strtab_hdr = nullptr;
	table = nullptr;

	/* See if we already have a symbol table for this library */
	if (m_SymTable.lib_base == dlmap->l_addr)
		table = &m_SymTable.table;

	/* If we don't have a symbol table for this library, then create one */
	if (table == nullptr)
	{
		m_SymTable.table.Initialize();
		m_SymTable.lib_base = dlmap->l_addr;
		m_SymTable.last_pos = 0;
		table = &m_SymTable.table;
	}

	/* See if the symbol is already cached in our table */
	symbol_entry = table->FindSymbol(symbol, strlen(symbol));
	if (symbol_entry != nullptr)
	{
		return symbol_entry->address;
	}

	/* If symbol isn't in our table, then we have open the actual library */
	dlfile = open(dlmap->l_name, O_RDONLY);
	if (dlfile == -1 || fstat(dlfile, &dlstat) == -1)
	{
		close(dlfile);
		return nullptr;
	}

	/* Map library file into memory */
	file_hdr = (ElfHeader *)mmap(nullptr, dlstat.st_size, PROT_READ, MAP_PRIVATE, dlfile, 0);
	map_base = (uintptr_t)file_hdr;
	if (file_hdr == MAP_FAILED)
	{
		close(dlfile);
		return nullptr;
	}
	close(dlfile);

	if (file_hdr->e_shoff == 0 || file_hdr->e_shstrndx == SHN_UNDEF)
	{
		munmap(file_hdr, dlstat.st_size);
		return nullptr;
	}

	sections = (ElfSHeader *)(map_base + file_hdr->e_shoff);
	section_count = file_hdr->e_shnum;
	/* Get ELF section header string table */
	shstrtab_hdr = &sections[file_hdr->e_shstrndx];
	shstrtab = (const char *)(map_base + shstrtab_hdr->sh_offset);

	/* Iterate sections while looking for ELF symbol table and string table */
	for (uint16_t i = 0; i < section_count; i++)
	{
		ElfSHeader &hdr = sections[i];
		const char *section_name = shstrtab + hdr.sh_name;

		if (strcmp(section_name, ".symtab") == 0)
		{
			symtab_hdr = &hdr;
		}
		else if (strcmp(section_name, ".strtab") == 0)
		{
			strtab_hdr = &hdr;
		}
	}

	/* Uh oh, we don't have a symbol table or a string table */
	if (symtab_hdr == nullptr || strtab_hdr == nullptr)
	{
		munmap(file_hdr, dlstat.st_size);
		return nullptr;
	}

	symtab = (ElfSymbol *)(map_base + symtab_hdr->sh_offset);
	strtab = (const char *)(map_base + strtab_hdr->sh_offset);
	symbol_count = symtab_hdr->sh_size / symtab_hdr->sh_entsize;

	/* Iterate symbol table starting from the position we were at last time */
	for (uint32_t i = m_SymTable.last_pos; i < symbol_count; i++)
	{
		ElfSymbol &sym = symtab[i];
		unsigned char sym_type = ELF_SYM_TYPE(sym.st_info);
		const char *sym_name = strtab + sym.st_name;
		Symbol *cur_sym;

		/* Skip symbols that are undefined or do not refer to functions or objects */
		if (sym.st_shndx == SHN_UNDEF || (sym_type != STT_FUNC && sym_type != STT_OBJECT))
		{
			continue;
		}

		/* Caching symbols as we go along */
		cur_sym = table->InternSymbol(sym_name, strlen(sym_name), (void *)(dlmap->l_addr + sym.st_value));
		if (strcmp(symbol, sym_name) == 0)
		{
			symbol_entry = cur_sym;
			m_SymTable.last_pos = ++i;
			break;
		}
	}

	munmap(file_hdr, dlstat.st_size);
	return symbol_entry ? symbol_entry->address : nullptr;

#endif
}

bool MemoryUtils::GetLibraryInfo(const void *libPtr, DynLibInfo &lib)
{
	uintptr_t baseAddr;

	if (libPtr == nullptr)
	{
		return false;
	}

#ifdef WIN32

#ifdef PLATFORM_X86
	const WORD PE_FILE_MACHINE = IMAGE_FILE_MACHINE_I386;
	const WORD PE_NT_OPTIONAL_HDR_MAGIC = IMAGE_NT_OPTIONAL_HDR32_MAGIC;
#else
	const WORD PE_FILE_MACHINE = IMAGE_FILE_MACHINE_AMD64;
	const WORD PE_NT_OPTIONAL_HDR_MAGIC = IMAGE_NT_OPTIONAL_HDR64_MAGIC;
#endif

	MEMORY_BASIC_INFORMATION info;
	IMAGE_DOS_HEADER *dos;
	IMAGE_NT_HEADERS *pe;
	IMAGE_FILE_HEADER *file;
	IMAGE_OPTIONAL_HEADER *opt;

	if (!VirtualQuery(libPtr, &info, sizeof(MEMORY_BASIC_INFORMATION)))
	{
		return false;
	}

	baseAddr = reinterpret_cast<uintptr_t>(info.AllocationBase);

	/* All this is for our insane sanity checks :o */
	dos = reinterpret_cast<IMAGE_DOS_HEADER *>(baseAddr);
	pe = reinterpret_cast<IMAGE_NT_HEADERS *>(baseAddr + dos->e_lfanew);
	file = &pe->FileHeader;
	opt = &pe->OptionalHeader;

	/* Check PE magic and signature */
	if (dos->e_magic != IMAGE_DOS_SIGNATURE || pe->Signature != IMAGE_NT_SIGNATURE || opt->Magic != PE_NT_OPTIONAL_HDR_MAGIC)
	{
		return false;
	}

	/* Check architecture */
	if (file->Machine != PE_FILE_MACHINE)
	{
		return false;
	}

	/* For our purposes, this must be a dynamic library */
	if ((file->Characteristics & IMAGE_FILE_DLL) == 0)
	{
		return false;
	}

	/* Finally, we can do this */
	lib.memorySize = opt->SizeOfImage;
	lib.handle = (HMODULE)info.AllocationBase;

#elif defined PLATFORM_LINUX

#ifdef PLATFORM_X86
	typedef Elf32_Ehdr ElfHeader;
	typedef Elf32_Phdr ElfPHeader;
	const unsigned char ELF_CLASS = ELFCLASS32;
	const uint16_t ELF_MACHINE = EM_386;
#else
	typedef Elf64_Ehdr ElfHeader;
	typedef Elf64_Phdr ElfPHeader;
	const unsigned char ELF_CLASS = ELFCLASS64;
	const uint16_t ELF_MACHINE = EM_X86_64;
#endif

	Dl_info info;
	ElfHeader *file;
	ElfPHeader *phdr;
	uint16_t phdrCount;

	if (!dladdr(libPtr, &info))
	{
		return false;
	}

	if (!info.dli_fbase || !info.dli_fname)
	{
		return false;
	}

	/* This is for our insane sanity checks :o */
	baseAddr = reinterpret_cast<uintptr_t>(info.dli_fbase);
	file = reinterpret_cast<ElfHeader *>(baseAddr);

	/* Check ELF magic */
	if (memcmp(ELFMAG, file->e_ident, SELFMAG) != 0)
	{
		return false;
	}

	/* Check ELF version */
	if (file->e_ident[EI_VERSION] != EV_CURRENT)
	{
		return false;
	}

	/* Check ELF endianness */
	if (file->e_ident[EI_DATA] != ELFDATA2LSB)
	{
		return false;
	}

	/* Check ELF architecture */
	if (file->e_ident[EI_CLASS] != ELF_CLASS || file->e_machine != ELF_MACHINE)
	{
		return false;
	}

	/* For our purposes, this must be a dynamic library/shared object */
	if (file->e_type != ET_DYN)
	{
		return false;
	}

	phdrCount = file->e_phnum;
	phdr = reinterpret_cast<ElfPHeader *>(baseAddr + file->e_phoff);

	for (uint16_t i = 0; i < phdrCount; i++)
	{
		ElfPHeader &hdr = phdr[i];

		/* We only really care about the segment with executable code */
		if (hdr.p_type == PT_LOAD && hdr.p_flags == (PF_X | PF_R))
		{
			/* From glibc, elf/dl-load.c:
			 * c->mapend = ((ph->p_vaddr + ph->p_filesz + GLRO(dl_pagesize) - 1)
			 *             & ~(GLRO(dl_pagesize) - 1));
			 *
			 * In glibc, the segment file size is aligned up to the nearest page size and
			 * added to the virtual address of the segment. We just want the size here.
			 */
			lib.memorySize = PAGE_ALIGN_UP(hdr.p_filesz);
			break;
		}
	}

	// 获取句柄
	HMODULE handle = dlopen(info.dli_fname, RTLD_NOW);
	if (!handle)
		return false;
	dlclose(handle);
	lib.handle = handle;

#endif
	lib.baseAddress = reinterpret_cast<void *>(baseAddr);
	return true;
}
