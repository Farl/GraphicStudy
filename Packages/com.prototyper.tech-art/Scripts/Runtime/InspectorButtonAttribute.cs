using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SS
{
    #if !USE_SS_ESSENTIAL
    public class InspectorButtonAttribute : PropertyAttribute
    {
        public string label;
        public string method;
        public string[] labels;
        public string[] methods;

        public InspectorButtonAttribute(string label, string method)
        {
            this.label = label;
            this.method = method;
        }

        public InspectorButtonAttribute(string[] labels, string[] methods)
        {
            this.labels = labels;
            this.methods = methods;
        }
    }
    #endif
}
