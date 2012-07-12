using System;
using System.Collections.Generic;
using System.Text;

namespace LynnEditor
{
    public interface IUndoHandler
    {
        bool CanUndo { get; }
        bool CanRedo { get; }
        void Undo();
        void Redo();
    }
}
