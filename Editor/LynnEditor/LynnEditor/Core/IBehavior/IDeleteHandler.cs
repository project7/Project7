using System;
using System.Collections.Generic;
using System.Text;

namespace LynnEditor
{
    public interface IDeleteHandler
    {
        bool CanDelete { get; }
        void Delete();
    }
}
