package com.wudsn.ide.hex;

public interface FileContent {

    /**
     * Gets the length of the file content.
     * 
     * @return The length of the file content, a non-negative integer.
     */
    public int getLength();

    /**
     * Gets a byte (8 bit) from the file content.
     * 
     * @param offset
     *            The offset, a non-negative integer.
     * @return The byte from the file content.
     */
    public int getByte(long offset);

    /**
     * Gets a word (16 bit) in little endian format from the file content.
     * 
     * @param offset
     *            The offset, a non-negative integer.
     * @return The word from the file content.
     */
    public int getWord(long offset);

    /**
     * Gets a word (16 bit) in big endian format from the file content.
     * 
     * @param offset
     *            The offset, a non-negative integer.
     * @return The word from the file content.
     */
    public int getWordBigEndian(long offset);

    /**
     * Gets a double word (32 bit) in big endian format from the file content.
     * 
     * @param offset
     *            The offset, a non-negative integer.
     * @return The word from the file content.
     */
    public long getDoubleWordBigEndian(long offset);
}
