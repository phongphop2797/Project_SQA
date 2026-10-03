package org.apache.commons.lang3.math;
import java.math.BigInteger;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
public class NumberUtilsSymbolicHexTest {
    @Test public void path_00() {
        Number actual = NumberUtils.createNumber("0x0");
        assertEquals(new BigInteger("0"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_01() {
        Number actual = NumberUtils.createNumber("0xF");
        assertEquals(new BigInteger("15"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_02() {
        Number actual = NumberUtils.createNumber("-0x0");
        assertEquals(new BigInteger("0"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_03() {
        Number actual = NumberUtils.createNumber("-0xF");
        assertEquals(new BigInteger("-15"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_04() {
        Number actual = NumberUtils.createNumber("0x10000000");
        assertEquals(new BigInteger("268435456"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_05() {
        Number actual = NumberUtils.createNumber("0x7FFFFFFF");
        assertEquals(new BigInteger("2147483647"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_06() {
        Number actual = NumberUtils.createNumber("0x80000000");
        assertEquals(new BigInteger("2147483648"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_07() {
        Number actual = NumberUtils.createNumber("0xFFFFFFFF");
        assertEquals(new BigInteger("4294967295"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_08() {
        Number actual = NumberUtils.createNumber("-0x10000000");
        assertEquals(new BigInteger("-268435456"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_09() {
        Number actual = NumberUtils.createNumber("-0x80000000");
        assertEquals(new BigInteger("-2147483648"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_10() {
        Number actual = NumberUtils.createNumber("-0x80000001");
        assertEquals(new BigInteger("-2147483649"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_11() {
        Number actual = NumberUtils.createNumber("-0xFFFFFFFF");
        assertEquals(new BigInteger("-4294967295"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_12() {
        Number actual = NumberUtils.createNumber("0x100000000");
        assertEquals(new BigInteger("4294967296"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_13() {
        Number actual = NumberUtils.createNumber("0xFFFFFFFFF");
        assertEquals(new BigInteger("68719476735"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_14() {
        Number actual = NumberUtils.createNumber("-0x100000000");
        assertEquals(new BigInteger("-4294967296"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_15() {
        Number actual = NumberUtils.createNumber("-0xFFFFFFFFF");
        assertEquals(new BigInteger("-68719476735"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_16() {
        Number actual = NumberUtils.createNumber("0x1000000000000000");
        assertEquals(new BigInteger("1152921504606846976"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_17() {
        Number actual = NumberUtils.createNumber("0xFFFFFFFFFFFFFFFF");
        assertEquals(new BigInteger("18446744073709551615"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_18() {
        Number actual = NumberUtils.createNumber("-0x1000000000000000");
        assertEquals(new BigInteger("-1152921504606846976"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_19() {
        Number actual = NumberUtils.createNumber("-0xFFFFFFFFFFFFFFFF");
        assertEquals(new BigInteger("-18446744073709551615"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_20() {
        Number actual = NumberUtils.createNumber("0x10000000000000000");
        assertEquals(new BigInteger("18446744073709551616"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_21() {
        Number actual = NumberUtils.createNumber("0xFFFFFFFFFFFFFFFFF");
        assertEquals(new BigInteger("295147905179352825855"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_22() {
        Number actual = NumberUtils.createNumber("-0x10000000000000000");
        assertEquals(new BigInteger("-18446744073709551616"),
            new BigInteger(actual.toString()));
    }

    @Test public void path_23() {
        Number actual = NumberUtils.createNumber("-0xFFFFFFFFFFFFFFFFF");
        assertEquals(new BigInteger("-295147905179352825855"),
            new BigInteger(actual.toString()));
    }
}
