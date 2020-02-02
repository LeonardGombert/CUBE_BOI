using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;

public class HeadBehavior : MonoBehaviour
{
    //INPUT VALUES
    [SerializeField] float rotationAmount;
    [SerializeField] float radius;

    [SerializeField] GameObject toMove;

    //TWEEN VALUES
    public float timePassed;
    [SerializeField] float startPosition;
    [SerializeField] float endPosition;
    float change;
    float duration;
    [SerializeField] float shorterDuration;
    [SerializeField] float intitialDuration;

    float rightPosition = 3.9f;
    float leftPosition = -3.9f;

    bool resetTime;
    bool isCentered;


    // Start is called before the first frame update
    void Start()
    {
        isCentered = true;
        duration = intitialDuration;
    }

    // Update is called once per frame
    void Update()
    {
        MyShpere();
        toMove.transform.position = new Vector3(transform.position.x + rotationAmount, transform.position.y + Mathf.Sqrt(Mathf.Pow(radius, 2) - Mathf.Pow(rotationAmount, 2)), transform.position.z);
    }

    void MyShpere()
    {
        timePassed += Time.deltaTime;

        if (Input.GetKeyDown(KeyCode.RightArrow)) { timePassed = 0f; resetTime = false; startPosition = rotationAmount; if (rotationAmount != 0f) { isCentered = false; duration = shorterDuration; } }
        if (Input.GetKey(KeyCode.RightArrow)) { endPosition = rightPosition; }
        if (Input.GetKeyUp(KeyCode.RightArrow)) { resetTime = true; endPosition = 0; startPosition = 0; }

        if (Input.GetKeyDown(KeyCode.LeftArrow)) { timePassed = 0f; resetTime = false; startPosition = rotationAmount; if (rotationAmount != 0f) { isCentered = false; duration = shorterDuration; } }
        if (Input.GetKey(KeyCode.LeftArrow)) { endPosition = leftPosition;}
        if (Input.GetKeyUp(KeyCode.LeftArrow)) { resetTime = true; endPosition = 0; startPosition = 0; }

        change = endPosition - startPosition;

        if (timePassed <= duration && !resetTime)
        {
            if (!isCentered) rotationAmount = TweenManager.EaseInQuad(timePassed, startPosition, change, duration);
            if(isCentered) rotationAmount = TweenManager.EaseInExpo(timePassed, startPosition, change, duration);
        }

        if (timePassed >= duration || resetTime)
        {
            if(rotationAmount > 0f)
            {
                rotationAmount -= Time.deltaTime * 1f;
            }
            if (rotationAmount < 0f)
            {
                rotationAmount += Time.deltaTime * 1f;
            }

            if(rotationAmount > -0.1f && rotationAmount < 0.1f)
            {
                timePassed = 0f; 
                resetTime = false;
                isCentered = true;
                duration = intitialDuration;
            }
        }
    }
}