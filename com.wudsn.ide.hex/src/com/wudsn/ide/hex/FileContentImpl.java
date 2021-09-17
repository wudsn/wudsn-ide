package com.wudsn.ide.hex;

public class FileContentImpl implements FileContent {

	private byte[] fileContent;

	public FileContentImpl(byte[] fileContent) {
		if (fileContent == null) {
			throw new IllegalArgumentException("Parameter 'fileContent' must not be null.");
		}
		this.fileContent = fileContent;
	}

	/**
	 * Gets the length of the file content.
	 * 
	 * @return The length of the file content, a non-negative integer.
	 */
	@Override
	public int getLength() {
		return fileContent.length;
	}

	/**
	 * Gets a byte (8 bit) from the file content.
	 * 
	 * @param offset The offset, a non-negative integer.
	 * @return The byte from the file content.
	 */
	@Override
	public int getByte(long offset) {
		if (offset < 0) {
			throw new IllegalArgumentException("Parameter offset=" + offset + " must not be negative");
		}
		if (offset >= fileContent.length) {
			throw new IllegalArgumentException(
					"Parameter offset=" + offset + " must be less than the file content size " + fileContent.length);
		}
		return fileContent[(int) offset] & 0xff;
	}

	/**
	 * Gets a word (16 bit) in little endian format from the file content.
	 * 
	 * @param offset The offset, a non-negative integer.
	 * @return The word from the file content.
	 */
	@Override
	public int getWord(long offset) {
		return getByte(offset) + 0x100 * getByte(offset + 1);
	}

	/**
	 * Gets a word (16 bit) in big endian format from the file content.
	 * 
	 * @param offset The offset, a non-negative integer.
	 * @return The word from the file content.
	 */
	@Override
	public int getWordBigEndian(long offset) {
		return getByte(offset + 1) + 0x100 * getByte(offset);
	}

	/**
	 * Gets a double word (32 bit) in big endian format from the file content.
	 * 
	 * @param offset The offset, a non-negative integer.
	 * @return The word from the file content.
	 */
	@Override
	public long getDoubleWordBigEndian(long offset) {
		return getWordBigEndian(offset + 2) + 0x10000 * getWordBigEndian(offset);
	}
}
