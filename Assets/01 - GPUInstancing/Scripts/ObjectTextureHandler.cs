using UnityEngine;

public class ObjectTextureHandler : MonoBehaviour
{
    public Vector4 m_TextureCellAndDimension;
    public Vector4 m_TextureTilingAndOffset;
    
    private void Start()
    {
        // Create property block and set to the mesh.
        MaterialPropertyBlock propertyBlock = new MaterialPropertyBlock();
        propertyBlock.SetVector("_TextureCellDim", m_TextureCellAndDimension);
        propertyBlock.SetVector("_TextureST", m_TextureTilingAndOffset);        
        GetComponent<MeshRenderer>().SetPropertyBlock(propertyBlock);
    }
}
