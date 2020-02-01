using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialProp : MonoBehaviour
{

    private MaterialPropertyBlock m_PropertyBlock;
    private Renderer myRenderer;

    public float _Value;
    public float _Speed;
    [Range(0,0.01f)]public float _Outline;
    public float _Width;

    [Space(10)]
    public float _Test1;
    public float _Test2;
    public float _Disorder;

    void Start()
    {
        myRenderer = GetComponent<Renderer>();
        m_PropertyBlock = new MaterialPropertyBlock();
    }

    void Update()
    {

        m_PropertyBlock.SetFloat("_Value", _Value);
        m_PropertyBlock.SetFloat("_Speed", _Speed);
        m_PropertyBlock.SetFloat("_Outline", _Outline);
        m_PropertyBlock.SetFloat("_Width", _Width);
        m_PropertyBlock.SetFloat("_Test1", _Test1);
        m_PropertyBlock.SetFloat("_Test2", _Test2);
        m_PropertyBlock.SetFloat("_Disorder", _Disorder);
        myRenderer.SetPropertyBlock(m_PropertyBlock);
    }
}
