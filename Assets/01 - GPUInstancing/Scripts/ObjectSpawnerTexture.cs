using System.Collections;
using UnityEngine;

public class ObjectSpawnerTexture : MonoBehaviour
{
    public GameObject m_ObjectPrefab;
    public float m_SpawningInterval = 1f;

	// Use this for initialization
	void Start ()
    {
        StartCoroutine(SpawObjects());
	}

    IEnumerator SpawObjects()
    {
        WaitForSeconds waitForInterval = new WaitForSeconds(m_SpawningInterval);
        while (true)
        {
            GameObject go = Instantiate(m_ObjectPrefab, transform);
            go.transform.parent = transform;
            go.GetComponent<Rigidbody>().AddForce(new Vector3(Random.Range(0f, 100f), Random.Range(0f, 100f), Random.Range(0f, 100f)));

            ObjectTextureHandler oph = go.AddComponent<ObjectTextureHandler>();
            
            // Choose random texture cell, tiling and offset.
            oph.m_TextureCellAndDimension = new Vector4(Mathf.Round(Random.Range(0.0f, 1.0f)), Mathf.Round(Random.Range(0.0f, 1.0f)), 2, 2);
            float tiling = Random.Range(1.0f, 3.0f);
            oph.m_TextureTilingAndOffset = new Vector4(tiling, tiling, Random.Range(0f,1f), Random.Range(0f,1f));

            yield return waitForInterval;
        }
    }

    // Show spawning point.
    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, 0.1f);
    }
}
