using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using System.Collections.Generic;
using ScintillaNet;
using WeifenLuo.WinFormsUI;

namespace LynnEditor
{
    public class ScriptEditor : AbstractEditor
    {
        Scintilla editor;

        public ScriptEditor(ScriptFile item) : base(item)
        {
            
            editor = new Scintilla();
            editor.Dock = DockStyle.Fill;
            editor.Font = new Font("ÑÅºÚËÎÌå", 12);
            this.Controls.Add(editor);
            #region "Sci Editor Config"
            // http://ondineyuga.com/svn/RGE2/Tools/RGESEditor/RGESEditor_lang/EditorScintilla/Scintilla.cs
            // line number
            editor.Margins[0].Width = 39;

            // fold
            editor.Margins[1].Type = MarginType.Symbol;
            editor.Margins[1].Mask = -33554432; //SC_MASK_FOLDERS
            editor.Margins[1].Width = 16;
            editor.Margins[1].IsClickable = true;
            editor.NativeInterface.SetProperty("fold", "1");
            editor.NativeInterface.SetProperty("fold.comment", "0");
            editor.NativeInterface.SetProperty("fold.compact", "1");
            editor.NativeInterface.SetProperty("fold.preprocessor", "1");
    
            editor.Folding.Flags = FoldFlag.LineAfterContracted;

            // lexing
            editor.Lexing.Lexer = Lexer.Ruby;
            editor.Lexing.SetKeywords(0, "__FILE__ __LINE__ BEGIN END alias and begin break case class def defined? do else elsif end ensure false for if in module next nil not or redo rescue retry return self super then true undef unless until when while yield");
            editor.Styles.ClearAll();
            editor.UseFont = true;
            editor.Styles[(int)SCE_RB.DEFAULT].ForeColor = Color.FromArgb(0, 0, 0);
            editor.Styles[(int)SCE_RB.DEFAULT].BackColor = Color.FromArgb(255, 255, 255);
            editor.Styles[(int)SCE_RB.WORD].ForeColor = Color.FromArgb(0, 0, 127);
            editor.Styles[(int)SCE_RB.WORD_DEMOTED].ForeColor = Color.FromArgb(0, 0, 127);
            editor.Styles[(int)SCE_RB.STRING].ForeColor = Color.FromArgb(127, 0, 151);
            editor.Styles[(int)SCE_RB.GLOBAL].ForeColor = Color.FromArgb(180, 0, 180);
            editor.Styles[(int)SCE_RB.CLASSNAME].ForeColor = Color.FromArgb(0, 0, 255);
            editor.Styles[(int)SCE_RB.MODULE_NAME].ForeColor = Color.FromArgb(160, 0, 160);
            editor.Styles[(int)SCE_RB.CLASS_VAR].ForeColor = Color.FromArgb(128, 0, 204);
            editor.Styles[(int)SCE_RB.INSTANCE_VAR].ForeColor = Color.FromArgb(176, 0, 128);
            editor.Styles[(int)SCE_RB.NUMBER].ForeColor = Color.FromArgb(0, 127, 127);
            editor.Styles[(int)SCE_RB.STRING_Q].ForeColor = Color.FromArgb(127, 0, 151);
            editor.Styles[(int)SCE_RB.STRING_QQ].ForeColor = Color.FromArgb(127, 0, 151);
            editor.Styles[(int)SCE_RB.STRING_QX].ForeColor = Color.FromArgb(127, 0, 151);
            editor.Styles[(int)SCE_RB.STRING_QR].ForeColor = Color.FromArgb(127, 0, 151);
            editor.Styles[(int)SCE_RB.STRING_QW].ForeColor = Color.FromArgb(127, 0, 151);
            editor.Styles[(int)SCE_RB.REGEX].ForeColor = Color.FromArgb(120, 0, 170);
            editor.Styles[(int)SCE_RB.SYMBOL].ForeColor = Color.FromArgb(205, 100, 30);
            editor.Styles[(int)SCE_RB.DEFNAME].ForeColor = Color.FromArgb(0, 127, 127);
            editor.Styles[(int)SCE_RB.BACKTICKS].ForeColor = Color.FromArgb(160, 65, 10);
            editor.Styles[(int)SCE_RB.HERE_DELIM].ForeColor = Color.FromArgb(0, 137, 0);
            editor.Styles[(int)SCE_RB.HERE_Q].ForeColor = Color.FromArgb(127, 0, 151);
            editor.Styles[(int)SCE_RB.HERE_QQ].ForeColor = Color.FromArgb(127, 0, 151);
            editor.Styles[(int)SCE_RB.HERE_QX].ForeColor = Color.FromArgb(0, 137, 0);
            editor.Styles[(int)SCE_RB.DATASECTION].ForeColor = Color.FromArgb(127, 0, 0);
            editor.Styles[(int)SCE_RB.COMMENTLINE].ForeColor = Color.FromArgb(0, 127, 0);
            editor.Styles[(int)SCE_RB.POD].ForeColor = Color.FromArgb(0, 127, 0);

            editor.EndOfLine.Mode = EndOfLineMode.Crlf;
            editor.LineWrap.Mode = WrapMode.None;

            editor.Indentation.UseTabs = false;
            editor.Indentation.TabIndents = true;
            editor.Indentation.TabWidth = 2;
            editor.Indentation.ShowGuides = false;
            editor.Indentation.BackspaceUnindents = true;
            editor.Indentation.IndentWidth = 2;
            editor.Indentation.SmartIndentType = SmartIndent.Simple;

            editor.LongLines.EdgeMode = EdgeMode.Line;
            editor.LongLines.EdgeColumn = 160;

            editor.Caret.HighlightCurrentLine = true;
            editor.Caret.CurrentLineBackgroundColor = Color.FromArgb(240, 240,240);
            #endregion

            editor.Text = (this.File as ScriptFile).Code;
            editor.UndoRedo.EmptyUndoBuffer();
            editor.TextDeleted += new EventHandler<TextModifiedEventArgs>(editor_TextDeleted);
            editor.TextInserted += new EventHandler<TextModifiedEventArgs>(editor_TextInserted);
            editor.Scrolling.HorizontalWidth = 1;

            editor.CharAdded += new EventHandler<CharAddedEventArgs>(editor_CharAdded);

            this.FormClosing += new FormClosingEventHandler(ScriptEditor_FormClosing);
        }

        public override void Commit()
        {
            (File as ScriptFile).Code = this.editor.Text;
        }

        void ScriptEditor_FormClosing(object sender, FormClosingEventArgs e)
        {
            this.Commit();
        }

        void editor_CharAdded(object sender, CharAddedEventArgs e)
        {
            if ((e.Ch == 10 || e.Ch == 13) && editor.Lines.Current.Number > 0)
            {
                int ind = editor.Lines.Current.Indentation - 1;
                if ((editor.Lines.Current.Number == 1 &&
                     editor.Lines[editor.Lines.Current.Number - 1].FoldLevel > 1024) ||
                    (editor.Lines.Current.Number > 1 &&
                     editor.Lines[editor.Lines.Current.Number - 1].FoldLevel >
                     editor.Lines[editor.Lines.Current.Number - 2].FoldLevel))
                {
                    ind += editor.Indentation.IndentWidth;
                }
                if (ind > 0)
                {
                    editor.Lines.Current.Indentation = ind;
                    editor.GoTo.Position(editor.Lines.Current.StartPosition + ind);
                }
            }
            /*
              def on_editor_char_added chr
                curr_line = @editor.get_current_line
                if [10, 13].include? chr and curr_line > 0
                  line_ind = @editor.get_line_indentation curr_line - 1
                  if (curr_line == 1 and @editor.get_fold_level(curr_line - 1) > 1024) or 
                    (curr_line > 1 and @editor.get_fold_level(curr_line - 1) >
                    @editor.get_fold_level(curr_line - 2))
                    line_ind += @editor.get_indent
                  # FIXME: auto "unindent"
                  #elsif get_line(curr_line - 1).strip == 'end'
                  #  line_ind -= get_indent
                  #  line_ind = 0 if line_ind < 0
                  #  set_line_indentation curr_line - 1, line_ind
                  #elsif get_line(curr_line - 1).strip == 'else'
                  #  set_line_indentation curr_line - 1, line_ind - get_indent
                  end
                  if line_ind > 0
                    @editor.set_line_indentation curr_line, line_ind
                    @editor.goto_pos @editor.position_from_line(curr_line) + line_ind
                  end
                end
              end
            */
        }

        void editor_TextInserted(object sender, TextModifiedEventArgs e)
        {
            this.File.MakeDirty();
        }

        void editor_TextDeleted(object sender, TextModifiedEventArgs e)
        {
            this.File.MakeDirty();
        }

        
    }

    public enum SCE_RB
    {
        DEFAULT = 0,
        ERROR = 1,
        COMMENTLINE = 2,
        POD = 3,
        NUMBER = 4,
        WORD = 5,
        STRING = 6,
        CHARACTER = 7,
        CLASSNAME = 8,
        DEFNAME = 9,
        OPERATOR = 10,
        IDENTIFIER = 11,
        REGEX = 12,
        GLOBAL = 13,
        SYMBOL = 14,
        MODULE_NAME = 15,
        INSTANCE_VAR = 16,
        CLASS_VAR = 17,
        BACKTICKS = 18,
        DATASECTION = 19,
        HERE_DELIM = 20,
        HERE_Q = 21,
        HERE_QQ = 22,
        HERE_QX = 23,
        STRING_Q = 24,
        STRING_QQ = 25,
        STRING_QX = 26,
        STRING_QR = 27,
        STRING_QW = 28,
        WORD_DEMOTED = 29,
        STDIN = 30,
        STDOUT = 31,
        STDERR = 40,
        UPPER_BOUND = 41
    }
}
