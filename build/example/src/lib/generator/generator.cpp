#include "generator.h"

#include <boost/date_time/posix_time/posix_time.hpp>

boost::container::string generate_message()
{
    boost::container::string result = "hello, world at ";
    result += boost::posix_time::to_simple_string(boost::posix_time::microsec_clock::local_time()).c_str();
    return result;
}
