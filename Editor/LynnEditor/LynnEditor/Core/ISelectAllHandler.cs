using System;
using System.Collections.Generic;
using System.Text;

namespace LynnEditor
{
    public interface ISelectAllHandler
    {
        bool CanSelectAll { get; }
        void SelectAll();
    }
}
