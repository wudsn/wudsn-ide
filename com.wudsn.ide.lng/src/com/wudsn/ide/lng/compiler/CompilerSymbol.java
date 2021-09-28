/**
 * Copyright (C) 2009 - 2021 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
 *
 * This file is part of WUDSN IDE.
 * 
 * WUDSN IDE is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 * 
 * WUDSN IDE is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with WUDSN IDE.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.wudsn.ide.lng.compiler;

import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.StringUtility;

/**
 * A symbols in the symbol table. A symbol may be an equate or a label and it
 * may represent a numeric numericValue or an address.
 * 
 * @author Peter Dell
 */
public final class CompilerSymbol {

	public static final int NUMBER = 1;
	public static final int STRING = 2;

	private final int type;
	private final String name;
	private final String nameUpperCase;
	private final String bankString;
	private final int valueType;
	private final String numberValueHexString;
	private final String numberValueHexStringUpperCase;
	private final String numberValueDecimalString;
	private final String stringValue;
	private final String stringValueUpperCase;

	public static final int UNDEFINED_BANK = -1;

	private CompilerSymbol(int type, String name, int bank, int valueType, long numberValue, String stringValue) {
		if (name == null)
			throw new IllegalArgumentException("Parameter 'name' must not be null.");
		if (StringUtility.isEmpty(name)) {
			throw new IllegalArgumentException("Parameter 'name' must not be empty.");
		}
		if (stringValue == null) {
			throw new IllegalArgumentException("Parameter 'stringValue' must not be null.");
		}
		this.type = type;
		this.name = name.trim();
		this.nameUpperCase = name.toUpperCase();
		this.bankString = bank != UNDEFINED_BANK ? NumberUtility.getLongValueDecimalString(bank) : "";
		this.valueType = valueType;
		switch (valueType) {
		case NUMBER:
			numberValue = numberValue & 0xfffffff;
			int length = (HexUtility.getLongValueHexLength(numberValue) + 1) & 0xffffffe;
			this.numberValueHexString = HexUtility.getLongValueHexString(numberValue, length);
			this.numberValueHexStringUpperCase = numberValueHexString.toUpperCase();
			this.numberValueDecimalString = NumberUtility.getLongValueDecimalString(numberValue);
			this.stringValue = "";
			this.stringValueUpperCase = stringValue;
			break;
		case STRING:
			this.numberValueHexString = "";
			this.numberValueHexStringUpperCase = "";
			this.numberValueDecimalString = "";
			this.stringValue = stringValue;
			this.stringValueUpperCase = stringValue.toUpperCase();
			break;
		default:
			throw new IllegalArgumentException("Value type '" + valueType + "' is not supported.");
		}
	}

	public static CompilerSymbol createNumberSymbol(int type, String name, int bank, long numberValue) {
		return new CompilerSymbol(type, name, bank, NUMBER, numberValue, "");
	}

	public static CompilerSymbol createNumberHexSymbol(String name, String hexValue) throws NumberFormatException {
		return new CompilerSymbol(CompilerSymbolType.DEFAULT, name, UNDEFINED_BANK, NUMBER,
				Long.parseLong(hexValue, 16), "");
	}

	public static CompilerSymbol createStringSymbol(String name, String stringValue) {
		return new CompilerSymbol(CompilerSymbolType.DEFAULT, name, UNDEFINED_BANK, STRING, 0, stringValue);
	}

	public int getType() {
		return type;
	}

	public String getName() {
		return name;
	}

	public String getNameUpperCase() {
		return nameUpperCase;
	}

	public String getBankString() {
		return bankString;
	}

	public String getValueAsHexString() {
		return numberValueHexString;
	}

	/**
	 * Upper case version of the hex string for fuzzy search.
	 * 
	 * @return The upper case version of the hex string.
	 */
	public String getValueAsHexStringUpperCase() {
		return numberValueHexStringUpperCase;
	}

	public String getValueAsDecimalString() {
		return numberValueDecimalString;
	}

	public String getValueAsString() {
		return stringValue;
	}

	/**
	 * Upper case version of the hex string for fuzzy search.
	 * 
	 * @return The upper case version of the hex string.
	 */
	public String getValueAsStringUpperCase() {
		return stringValueUpperCase;
	}

	@Override
	public String toString() {
		switch (valueType) {
		case NUMBER:
			return name + "=" + getValueAsHexString();
		case STRING:
			return name + "=" + getValueAsString();
		}
		throw new IllegalStateException();

	}
}
