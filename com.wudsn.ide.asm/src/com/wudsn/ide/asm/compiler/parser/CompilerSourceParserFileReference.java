package com.wudsn.ide.asm.compiler.parser;

public final class CompilerSourceParserFileReference {

	private int type;
	private int directiveEndOffset;

	/**
	 * Creation is public.
	 */
	public CompilerSourceParserFileReference() {
		type = CompilerSourceParserFileReferenceType.NONE;
		directiveEndOffset = 0;

	}

	/**
	 * Sets the type of the include.
	 * 
	 * @param type
	 *            The type of the include, see
	 *            {@link CompilerSourceParserFileReferenceType}.
	 */
	public void setType(int type) {
		switch (type) {
		case CompilerSourceParserFileReferenceType.SOURCE:
		case CompilerSourceParserFileReferenceType.BINARY:
			break;

		default:
			throw new IllegalArgumentException("Illegal include type " + type
					+ ".");
		}
		this.type = type;
	}

	/**
	 * Get the type of the include.
	 * 
	 * @return The type of the include, see
	 *         {@link CompilerSourceParserFileReferenceType}.
	 */
	public int getType() {
		return type;
	}

	/**
	 * Sets the include directive end offset. The value must be the offset of
	 * first character after the directive.
	 * 
	 * @param directiveEndOffset
	 *            The include directive end offset, a non-negative integer.
	 */
	public void setDirectiveEndOffset(int directiveEndOffset) {
		if (directiveEndOffset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'directiveEndOffset' must not be be negative. Specified value was "
							+ directiveEndOffset + ".");
		}
		this.directiveEndOffset = directiveEndOffset;
	}

	/**
	 * Gets the include directive end offset.
	 * 
	 * @return The include directive end offset, a non-negative integer.
	 */
	public int getDirectiveEndOffset() {
		return directiveEndOffset;
	}

}
