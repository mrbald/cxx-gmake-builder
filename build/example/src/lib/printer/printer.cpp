#include "printer.h"

#include <lib/generator/generator.h>

void print_message(std::ostream& out)
{
    out << generate_message() << std::endl;
}
