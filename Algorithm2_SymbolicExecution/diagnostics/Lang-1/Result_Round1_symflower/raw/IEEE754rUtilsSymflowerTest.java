package org.apache.commons.lang3.math;

import org.junit.*;
import static org.junit.Assert.*;

public class IEEE754rUtilsSymflowerTest {
	@Test(expected = IllegalArgumentException.class)
	public void max1() throws IllegalArgumentException {
		float[] array = null;
		IEEE754rUtils.max(array);
	}

	@Test(expected = IllegalArgumentException.class)
	public void max2() throws IllegalArgumentException {
		float[] array = {};
		IEEE754rUtils.max(array);
	}

	@Test
	public void max3() {
		float[] array = { 0.0F };
		float expected = 0.0F;
		float actual = IEEE754rUtils.max(array);

		assertEquals(expected, actual, 0.0000001F);
	}

	@Test(expected = IllegalArgumentException.class)
	public void max4() throws IllegalArgumentException {
		double[] array = null;
		IEEE754rUtils.max(array);
	}

	@Test(expected = IllegalArgumentException.class)
	public void max5() throws IllegalArgumentException {
		double[] array = {};
		IEEE754rUtils.max(array);
	}

	@Test
	public void max6() {
		double[] array = { 0.0D };
		double expected = 0.0D;
		double actual = IEEE754rUtils.max(array);

		assertEquals(expected, actual, 0.0000001D);
	}

	@Test(expected = IllegalArgumentException.class)
	public void min7() throws IllegalArgumentException {
		float[] array = null;
		IEEE754rUtils.min(array);
	}

	@Test(expected = IllegalArgumentException.class)
	public void min8() throws IllegalArgumentException {
		float[] array = {};
		IEEE754rUtils.min(array);
	}

	@Test
	public void min9() {
		float[] array = { 0.0F };
		float expected = 0.0F;
		float actual = IEEE754rUtils.min(array);

		assertEquals(expected, actual, 0.0000001F);
	}

	@Test(expected = IllegalArgumentException.class)
	public void min10() throws IllegalArgumentException {
		double[] array = null;
		IEEE754rUtils.min(array);
	}

	@Test(expected = IllegalArgumentException.class)
	public void min11() throws IllegalArgumentException {
		double[] array = {};
		IEEE754rUtils.min(array);
	}

	@Test
	public void min12() {
		double[] array = { 0.0D };
		double expected = 0.0D;
		double actual = IEEE754rUtils.min(array);

		assertEquals(expected, actual, 0.0000001D);
	}
}
