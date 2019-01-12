/**
 * Copyright (C) 2009 - 2019 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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
package com.wudsn.ide.snd.player.atari8;

import javax.sound.sampled.SourceDataLine;

import net.sf.asap.ASAP;
import net.sf.asap.ASAPSampleFormat;

import com.wudsn.ide.snd.player.SoundGenerator;

/**
 * Sound generator for {@link ASAPPlayer}.
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
final class ASAPSoundGenerator extends SoundGenerator {
    private final ASAP asap;
    private final SourceDataLine line;
    private final byte[] buffer;
    private int len;

    public ASAPSoundGenerator(ASAP asap, SourceDataLine line) {
	if (asap == null) {
	    throw new IllegalArgumentException("Parameter 'asap' must not be null.");
	}
	if (line == null) {
	    throw new IllegalArgumentException("Parameter 'line' must not be null.");
	}
	this.asap = asap;
	this.line = line;
	buffer = new byte[line.getBufferSize()];

	line.start();

    }

    @Override
    public void generateBuffer() {
	len = asap.generate(buffer, buffer.length, ASAPSampleFormat.S16_L_E);
    }

    @Override
    public void playBuffer() {
	line.write(buffer, 0, len);
    }

    @Override
    public boolean isGenerating() {
	return len == buffer.length;
    }

    @Override
    public void close() {
	line.drain();
	line.close();
    }
}