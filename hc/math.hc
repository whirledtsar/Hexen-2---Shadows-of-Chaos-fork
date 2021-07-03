/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/portals/math.hc,v 1.2 2007-02-07 16:59:34 sezero Exp $
 */



/*
 * crandom() -- Returns a random number between -1 and 1.
 */

float crandom()
{
	return random(-1,1);
}

/*
float fexp(float base,float exponent)
{//MG
float exp_count;

	exponent=rint(exponent);
	if(exponent==0)
		return 1;
	if(exponent<0)
	{
		base=1/base;
		exponent=fabs(exponent);
	}

	if(exponent==1)
		return base;
	
	exponent-=1;
	while(exp_count<exponent)
	{
		exp_count+=1;
		base=base*base;
	}
	return base;
}
*/

float byte_me(float mult)
{//MG
float mult_count,base;


	mult=rint(mult);
	if(mult==0)
		return 0;
	if(mult==1)
		return 1;
	if(mult==-1)
		return -1;

	if(mult<0)
	{
		base= -1;
		mult=fabs(mult);
	}
	else
		base=1;
	
	mult-=1;	
	while(mult_count<mult)
	{
		mult_count+=1;
		base=base*2;
	}
	return base;
}

vector RandomVector (vector vrange)
{
vector newvec;
	newvec_x=random(vrange_x,0-vrange_x);
	newvec_y=random(vrange_y,0-vrange_y);
	newvec_z=random(vrange_z,0-vrange_z);
	return newvec;
}

/*
 * math.qc
 *
 * Author: Joshua Skelton joshua.skelton@gmail.com
 *
 * A collection of helpful math functions.
 */
 
 /*
 * clamp
 *
 * Limits the given value to the given range.
 *
 * value: A number
 *
 * minValue: The minimum value of the range
 *
 * maxValue: The maximum value of the range
 *
 * Returns: A number within the given range.
 */
float(float value, float minValue, float maxValue) clamp = {
    if (value < minValue) {
        return minValue;
    }
    else if (value > maxValue) {
        return maxValue;
    }

    return value;
};
 
 /*
 * mod
 *
 * Returns the remainder after the division of a by n
 *
 * a: The dividend
 *
 * b: The divisor
 *
 * Returns: The remainder of a divided by n
 */
float(float a, float n) mod = {
    return a - (n * floor(a / n));
};
 
 /*
 * sign
 *
 * Returns an indication of the sign of the given number.
 *
 * x: A number
 *
 * Returns: -1 if x < 0, 0 if x == 0, 1 if x > 0.
 */
float(float x) sign = {
    if (x > 0) {
        return 1;
    }
    else if (x < 0) {
        return -1;
    }

    return 0;
};

/*
 * wrap
 *
 * Limits the given value to the given range and will wrap the value to the
 * the other end of the range if exceeded.
 *
 * value: A number
 *
 * minValue: The minimum value of the range
 *
 * maxValue: The maximum value of the range
 *
 * Returns: A number within the given range.
 */
float(float value, float minValue, float maxValue) wrap = {
    local float range = maxValue - minValue;

    return mod(value - minValue, range + 1) + minValue;
};

//ws: returns either -1 or 1
float randomsign ()
{
	if (random()<0.5)
		return -1;
	
	return 1;
}
