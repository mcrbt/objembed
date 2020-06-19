/**
 *
 *          Copyright Daniel Haase 2020.
 * Distributed under the Boost Software License, Version 1.0.
 *      (See accompanying file LICENSE or copy at
 *        https://www.boost.org/LICENSE_1_0.txt)
 *
 * This file belongs to objembed.
 *
 * Author: Daniel Haase
 *
 */

#include <stdio.h>

extern char _binary_version_txt_start;
extern char _binary_version_txt_end;

int main(void)
{
	char *txtseg = &_binary_version_txt_start;
	while(txtseg != &_binary_version_txt_end)
		putchar(*txtseg++);
	return 0;
}
