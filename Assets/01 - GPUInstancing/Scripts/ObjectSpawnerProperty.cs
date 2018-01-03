using System.Collections;
using UnityEngine;

public class ObjectSpawnerProperty : MonoBehaviour
{
    public GameObject m_ObjectPrefab;
    public float m_SpawningInterval = 1f;
    
	void Start ()
    {
        StartCoroutine(SpawnObjects());
	}

    IEnumerator SpawnObjects()
    {
        WaitForSeconds waitForInterval = new WaitForSeconds(m_SpawningInterval);
        while (true)
        {
            GameObject go = Instantiate(m_ObjectPrefab, transform);
            go.transform.parent = transform;
            go.GetComponent<Rigidbody>().AddForce(new Vector3(Random.Range(0f, 100f), Random.Range(0f, 100f), Random.Range(0f, 100f)));
            ObjectPropertyHandler oph = go.AddComponent<ObjectPropertyHandler>();

            // Choose random color.
            oph.m_Color = new Color(Random.Range(0f, 1f), Random.Range(0f, 1f), Random.Range(0f, 1f), 1f);

            yield return waitForInterval;
        }
    }

    // Show spawning point.
    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, 0.1f);
    }
}
