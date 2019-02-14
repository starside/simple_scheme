/*
 * Declarations for a calculator fb3-1
 */
/* interface to the lexer */
#include <stdint.h>

#ifndef FB3_2_H
#define FB3_2_H 

typedef uint8_t bool;

enum radix_tok		{r2, r8, r10, r16};
enum exactness_tok	{i, e, d};
enum sign_tok		{plus, minus};
enum base_tok		{b2, b8, b10, b16};
enum inf_tok		{inf_pos, inf_neg, na, inf};

typedef struct {
	bool empty;
	uint32_t width;
} mantissa_tok;

typedef struct
{
	enum radix_tok		radix;
	enum exactness_tok	exactness;
}prefix_tok;

typedef struct 
{
	uint64_t num, den;
	mantissa_tok mantissa_width;
}ureal_tok;

typedef struct {
	enum base_tok	base;
	enum sign_tok 	sign;
	enum inf_tok	inf;
	ureal_tok 		num;
}real_tok;

typedef struct {
	prefix_tok	prefix;
	real_tok 	re_im;
}number_tok;

typedef struct{
	real_tok real;
	int counter;
} temp_parse;

#endif