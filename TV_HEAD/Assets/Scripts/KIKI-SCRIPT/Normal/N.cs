using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class N : MonoBehaviour
{
    MaterialPropertyBlock matProp;
    Renderer rend;

    public float _Amount;

    // Start is called before the first frame update
    void Start()
    {
        matProp = new MaterialPropertyBlock();
        rend = GetComponent<Renderer>();
    }

    // Update is called once per frame
    void Update()
    {
        //matProp.SetFloat("_Amount", _Amount);
        //rend.SetPropertyBlock(matProp);
    }
}
