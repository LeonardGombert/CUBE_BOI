using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using UnityEngine.SceneManagement;

public class CharacterMovement : MonoBehaviour
{
    CharacterController characterController;

    [SerializeField] MaterialProp matPropHead;

    [Space(30)]
    [SerializeField] float speed = 12f;
    [SerializeField] float rotateSpeed = 12f;
    [SerializeField] float rotateAroundSpeed = 45f;
    [SerializeField] float rotateAroundSpeed2 = 2f;

    float xRotation;


    [SerializeField] Quaternion localRotation;

    // Range over which height varies.
    float heightScale = 10.0f;

    // Distance covered per second along X axis of Perlin plane.
    float xScale = .25f;


    float height;
    float height1;
    float height2;
    [SerializeField] float angleLimit;






    //INPUT VALUES
    [SerializeField] float rotationAmount;
    [SerializeField] float radius; 
    float rightPosition;
    float leftPosition;

[SerializeField] GameObject toMove;

    //TWEEN VALUES
    public float timePassed;
    float startPosition;
    float endPosition;
    float change;
    float duration;
    [SerializeField] float shorterDuration;
    [SerializeField] float intitialDuration;


    bool resetTime;
    bool isCentered;



    // Start is called before the first frame update
    void Start()
    {
        characterController = GetComponent<CharacterController>();
        isCentered = true;
        duration = intitialDuration;

        rightPosition = radius - 0.01f;
        leftPosition = -radius - 0.01f;
    }


    // Update is called once per frame
    void Update()
    {

        matPropHead._RotationHead = rotationAmount;

        MyAngle();
        MyShpere();
        toMove.transform.position = new Vector3(transform.localPosition.x + rotationAmount, transform.localPosition.y + Mathf.Sqrt(Mathf.Pow(radius, 2) - Mathf.Pow(rotationAmount, 2)), transform.localPosition.z);
    }

    void MyAngle()
    {
        localRotation = transform.rotation;

        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");

        Vector3 move = transform.right * x + transform.forward * z;

        height = heightScale * Mathf.PerlinNoise(Time.time * xScale, 0.0f);
        Vector3 pos = transform.position;
        pos.x = height;
        height1 = (float)CustomScaler.Scale(height, 0, 10, -10, 10);
        //transform.position = new Vector3(height, transform.position.y, transform.position.z);

        if (transform.rotation.eulerAngles.y < 360)
        {
            float clampValue = transform.rotation.y + height1;
            //transform.Rotate(0, height * rotateSpeed/2 * Time.deltaTime, 0, Space.Self);
            transform.RotateAround(transform.position, transform.up, Mathf.Clamp(clampValue, -10, 10) * rotateAroundSpeed2 * Time.deltaTime);// * rotateAroundSpeed/2 * Time.deltaTime);

            transform.Rotate(0, Input.GetAxis("Horizontal") * rotateSpeed * Time.deltaTime, 0, Space.Self);
            transform.RotateAround(transform.position, transform.up, Input.GetAxis("Horizontal") * rotateAroundSpeed * Time.deltaTime);
            Vector3 move3 = transform.forward + transform.right * x + transform.forward * z;
            characterController.Move(move3 * speed * Time.deltaTime);
        }

        else
        {
            Debug.Log("PD");
            return;
        }
    }

    void MyShpere()
    {
        height2 = (float)CustomScaler.Scale(height, 0, 10, leftPosition, rightPosition);

        rotationAmount += height2 * Time.deltaTime;

        timePassed += Time.deltaTime;

        if (Input.GetKeyDown(KeyCode.RightArrow)) { timePassed = 0f; resetTime = false; startPosition = rotationAmount; if (rotationAmount != 0f) { isCentered = false; duration = shorterDuration; } }
        if (Input.GetKey(KeyCode.RightArrow)) { endPosition = rightPosition; }
        if (Input.GetKeyUp(KeyCode.RightArrow)) { resetTime = true; endPosition = 0; startPosition = 0; }

        if (Input.GetKeyDown(KeyCode.LeftArrow)) { timePassed = 0f; resetTime = false; startPosition = rotationAmount; if (rotationAmount != 0f) { isCentered = false; duration = shorterDuration; } }
        if (Input.GetKey(KeyCode.LeftArrow)) { endPosition = leftPosition; }
        if (Input.GetKeyUp(KeyCode.LeftArrow)) { resetTime = true; endPosition = 0; startPosition = 0; }

        change = endPosition - startPosition;

        if (timePassed <= duration && !resetTime)
        {
            if (!isCentered) rotationAmount = TweenManager.EaseInQuad(timePassed, startPosition, change, duration);
            if (isCentered) rotationAmount = TweenManager.EaseInExpo(timePassed, startPosition, change, duration);
        }

        if (timePassed >= duration || resetTime)
        {
            if (rotationAmount > 0f)
            {
                rotationAmount -= Time.deltaTime * 1f;
            }
            if (rotationAmount < 0f)
            {
                rotationAmount += Time.deltaTime * 1f;
            }

            if (rotationAmount > -0.1f && rotationAmount < 0.1f)
            {
                timePassed = 0f;
                resetTime = false;
                isCentered = true;
                duration = intitialDuration;
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.name == "YES")
        {
            SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
        }
    }
}
