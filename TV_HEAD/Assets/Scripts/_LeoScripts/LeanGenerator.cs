using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LeanGenerator : MonoBehaviour
{
    // "Bobbing" animation from 1D Perlin noise.

    // Range over which height varies.
    float heightScale = 10.0f;

    // Distance covered per second along X axis of Perlin plane.
    float xScale = .25f;

    void Update()
    {        
        float height = heightScale * Mathf.PerlinNoise(Time.time * xScale, 0.0f);
        Vector3 pos = transform.position;
        pos.x = height;
        transform.position = new Vector3(height, transform.position.y, transform.position.z);

        Debug.Log(height);
    }
}
