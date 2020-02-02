using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialProp : MonoBehaviour
{

    private MaterialPropertyBlock m_PropertyBlock;
    private Renderer myRenderer;

    public float _Value = 0.0003f;
    public float _Speed = 70;
    [Range(0,0.01f)]public float _Outline = 0.001f;
    public float _Width = 1;

    [Space(10)]
    public float _Test1 = 0.1f;
    public float _Test2 = 3.71f;
    public float _Test3 = 3.71f;
    public float _Disorder = 0;

    [Space(10)]
    public bool isDisordered = false;
    public float _DirectionDisorderAmp;
    public Vector4 _DirectionDisorder;
    public Transform _DirectionDisorderPos;

    void Start()
    {
        myRenderer = GetComponent<Renderer>();
        m_PropertyBlock = new MaterialPropertyBlock();
    }

    void Update()
    {

        if (isDisordered == true)
        {
            _DirectionDisorder = _DirectionDisorderPos.localPosition;
            m_PropertyBlock.SetFloat("_Disorder", _Disorder);
            m_PropertyBlock.SetVector("_DirectionDisorder", _DirectionDisorder);
        }


        m_PropertyBlock.SetFloat("_Value", _Value);
        m_PropertyBlock.SetFloat("_Speed", _Speed);
        m_PropertyBlock.SetFloat("_Outline", _Outline);
        m_PropertyBlock.SetFloat("_Width", _Width);
        m_PropertyBlock.SetFloat("_Test1", _Test1);
        m_PropertyBlock.SetFloat("_Test2", _Test2);
        m_PropertyBlock.SetFloat("_Test3", _Test3);


        m_PropertyBlock.SetFloat("_Disorder", _Disorder);
        m_PropertyBlock.SetFloat("_DirectionDisorderAmp", _DirectionDisorderAmp);
        m_PropertyBlock.SetVector("_DirectionDisorder", _DirectionDisorder);
        myRenderer.SetPropertyBlock(m_PropertyBlock);
    }
}
