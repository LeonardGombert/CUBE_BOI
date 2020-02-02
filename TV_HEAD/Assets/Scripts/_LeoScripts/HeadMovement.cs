using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeadMovement : MonoBehaviour
{
    public Vector3 startPoint;
    public Vector3 endPoint;

    public float forceValue;

    public Rigidbody rb;
    public SpringJoint springJoint;
    private bool struckBall;

    float timePassed;
    float startValue;
    public float targetValue;
    float change;
    public float tweenDuration;
    public float weakSpringValue;

    Vector3 firstPressPos;
    Vector3 secondPressPos;
    Vector3 currentSwipe;

    public GameObject targetObject;

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


        if (Input.GetMouseButtonDown(0))
        {
            //save began touch 2d point
            firstPressPos = new Vector3(Input.mousePosition.x, 0, Input.mousePosition.z);
        }
        if (Input.GetMouseButtonUp(0))
        {
            //save ended touch 2d point
            secondPressPos = new Vector3(Input.mousePosition.x, 0, Input.mousePosition.z);

            //create vector from the two points
            currentSwipe = new Vector3(secondPressPos.x - firstPressPos.x, 0, secondPressPos.z - firstPressPos.z);

            currentSwipe.Normalize();

            rb.AddForce(currentSwipe * forceValue * Time.deltaTime, ForceMode.VelocityChange);
            targetObject.transform.rotation = Quaternion.AngleAxis(45, new Vector3(0, 0, 1));
            //targetObject.gameObject.transform.Rotate(45, 45, 45, Space.World);
            struckBall = true;
        }

        Vector3 move = transform.forward * z + transform.right * x;

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
