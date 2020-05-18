PASZLIB-SG
Copyright (C) 2003 by Sergey A. Galin.

This library is a modified version of PASZLIB (Copyright (C) 1998, 1999, 2000 
by NOMSSI NZALI Jacques H. C.), a Pascal port of zlib 1.1.2, a general purpose 
data compression library (Copyright (C) 1995-1998 by Mark Adler).



See README.txt in subdirectory paszlib for more information.

Major differences from PASZLIB 1.0
==================================
  
  1. May be compiled under Delphi 6+ and Kylix, but compatibility with older 
     Pascal versions is lost,
  2. Error handling (in all new units) is exception-driven. No need to back to 
     old "IOResult" style.     
  3. gzXXX functions operate on Streams (great flexibility!)
  4. TGZip class - handy object-oriented interface!
  5. Added more classes to allow multi-file store many compressed files
     in one stream...


Legal Issues
============

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the author be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
