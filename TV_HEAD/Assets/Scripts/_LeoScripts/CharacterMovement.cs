using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;

public class CharacterMovement : MonoBehaviour
{
    CharacterController characterController;
    [SerializeField] float speed = 12f;

    // Start is called before the first frame update
    void Start()
    {
        characterController = GetComponent<CharacterController>();
    }

    // Update is called once per frame
    void Update()
    {
        float x = Input.GetAxis("Horizontal");
        float y = Input.GetAxis("Vertical");

        Vector3 move = transform.right * x + transform.forward * y;

        characterController.Move(transform.forward * speed * Time.deltaTime);

        //transform.position = transform.forward * speed * Time.deltaTime;
    }
}
