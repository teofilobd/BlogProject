using UnityEngine;

public class ObjectPropertyHandler : MonoBehaviour
{
    public Color m_Color;

    private void Start()
    {
        // Create property block and set to the mesh.
        MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();
        propertyBlock.SetColor("_Color", m_Color);
        GetComponent<MeshRenderer>().SetPropertyBlock(propertyBlock);        
    }
}
