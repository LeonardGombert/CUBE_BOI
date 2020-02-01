using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeadMovement : MonoBehaviour
{
    public Vector3 startPoint;
    public Vector3 endPoint;

    public float forceValue = 1;

    public Rigidbody rb;
    public SpringJoint springJoint;
    private bool struckBall;

    float timePassed;
    float startValue;
    public float targetValue;
    float change;
    public float tweenDuration;
    public float weakSpringValue;

    // Start is called before the first frame update
    void Start()
    {
        startValue = springJoint.spring;
    }

    // Update is called once per frame
    void Update()
    {
        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");

        Vector3 move = transform.forward * z + transform.right * x;


        if (Input.GetKey(KeyCode.Space))
        {
            forceValue += 100f;
        }

        if (Input.GetKeyUp(KeyCode.Space))
        {
            rb.AddForce(move * forceValue * Time.deltaTime, ForceMode.VelocityChange);
            struckBall = true;
            forceValue = 1;
        }

        if (struckBall) increaseSpringJoint();
    }

    private void increaseSpringJoint()
    {
        springJoint.spring = weakSpringValue;

        timePassed += Time.deltaTime;

        change = targetValue - startValue;

        springJoint.spring = TweenManager.LinearTween(timePassed, startValue, change, tweenDuration);

        if(timePassed >= tweenDuration)
        {
            springJoint.spring = startValue;
            timePassed = 0f;
            struckBall = false;
        }
    }
}
