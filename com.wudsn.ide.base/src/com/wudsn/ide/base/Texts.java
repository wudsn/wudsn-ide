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

package com.wudsn.ide.base;

import org.eclipse.osgi.util.NLS;

import com.wudsn.ide.base.common.FileUtility;

/**
 * Class which holds the localized text constants.
 * 
 * @author Peter Dell
 */
public final class Texts extends NLS {

    /**
     * Common texts.
     */
    public static String DIALOG_TITLE;
    public static String FILE_PATH_FIELD_BROWSE_BUTTON_LABEL;
    public static String FILE_PATH_FIELD_DIALOG_MESSAGE;

    /**
     * Messages for {@link FileUtility}.
     */
    public static String MESSAGE_E200;
    public static String MESSAGE_E201;
    public static String MESSAGE_E202;
    public static String MESSAGE_E203;
    public static String MESSAGE_E204;
    public static String MESSAGE_E205;
    public static String MESSAGE_E206;
    public static String MESSAGE_E207;
    public static String MESSAGE_E208;
    public static String MESSAGE_E209;
    public static String MESSAGE_E210;
    public static String MESSAGE_E211;
    public static String MESSAGE_E212;
    public static String MESSAGE_E213;

    /**
     * Initializes the constants.
     */
    static {
	NLS.initializeMessages(Texts.class.getName(), Texts.class);
    }
}
