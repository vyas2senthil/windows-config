#!/bin/bash
set -e
cd ~/bin/linux/ext/
ext_download=(
    http://www.antlr.org/download/antlr-3.2.tar.gz
    http://www.antlr.org/download/antlr-3.2.jar
    http://www.antlr.org/download/antlrworks-1.3.1.jar
    http://www.stringtemplate.org/download/stringtemplate-3.2.1.tar.gz
)
for x in "${ext_download[@]}"; do 
    while ! wget --timeout 30 --connect-timeout 30 --tries 1 $x; do rm `basename $x`; done
done
mv antlr-3.2.jar antlr3.jar
tar zxfv stringtemplate*tar.gz
mv stringte*/lib/string*.jar stringtemplate.jar
mv antlrworks-1.3.1.jar antlrworks.jar
cd ~/.emacs_d/lisp/ext/

mkdir -p ~/Downloads/intel
cd ~/Downloads/intel


cat <<EOF|lftp
get -c http://download.intel.com/design/PentiumII/manuals/24319002.pdf -o "Intel Architecture Software Developer's Manual, Volume 1: Basic Architecture.pdf"
get -c http://download.intel.com/design/PentiumII/manuals/24319102.pdf -o "Intel Architecture Software Developer's Manual, Volume 2: Instruction Set Reference Manual.pdf"
get -c http://download.intel.com/design/PentiumII/manuals/24319202.pdf -o "Intel Architecture Software Developer's Manual, Volume 3: System Programming.pdf"
get -c http://www.intel.com/Assets/PDF/manual/318148.pdf -o "Intel® 64 Architecture x2APIC Specification.pdf"
get -c http://www.intel.com/Assets/PDF/manual/252046.pdf -o "Intel® 64 and IA-32 Architectures Software Developer's Manual, Documentation Changes.pdf"
get -c http://www.intel.com/Assets/PDF/manual/253665.pdf -o "Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 1: Basic Architecture.pdf"
get -c http://www.intel.com/Assets/PDF/manual/253666.pdf -o "Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 2A: Instruction Set Reference, A-M.pdf"
get -c http://www.intel.com/Assets/PDF/manual/253667.pdf -o "Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 2B: Instruction Set Reference, N-Z.pdf"
get -c http://www.intel.com/Assets/PDF/manual/253668.pdf -o "Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 3A: System Programming Guide.pdf"
get -c http://www.intel.com/Assets/PDF/manual/253669.pdf -o "Intel® 64 and IA-32 Architectures Software Developer's Manual, Volume 3B: System Programming Guide.pdf"
get -c http://www.intel.com/Assets/PDF/manual/248966.pdf -o "Intel® 64 and IA-32 Architectures Optimization Reference Manual.pdf"
get -c http://www.acpi.info/DOWNLOADS/ACPIspec40.pdf
EOF

echo OK
