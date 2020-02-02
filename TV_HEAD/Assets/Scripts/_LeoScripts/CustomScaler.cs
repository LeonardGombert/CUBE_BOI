using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomScaler : MonoBehaviour
{
    public static double Scale(float valueToScale, float valueMin, float valueMax, float minScaleTo, float maxScaleTo)
    {
        double scaledValue = minScaleTo + (double)(valueToScale - valueMin) / (valueMax - valueMin) * (maxScaleTo - minScaleTo);
        return scaledValue;
    }
}
