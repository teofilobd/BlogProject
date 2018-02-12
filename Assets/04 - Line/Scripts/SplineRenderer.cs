using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SplineRenderer : MonoBehaviour 
{
	public Transform [] m_ControlPoints;
	private List<Vector3> _IntermediatePoints;
	public float m_StepSize = 0.1f;

	public float m_LineWidth = 1f;
	private float _LineHalfWidth = 0.5f;

	public Material m_Material;

	public bool m_AdjustCorner = false;

	public bool m_FaceCamera = false;
	public Vector3 m_CustomNormal = Vector3.forward;

	private Mesh _Mesh = null;
	private List<Vector3> _Vertices = null;
	private List<int> _Triangles = null;
	private MeshFilter _MeshFilter = null;
	private MeshRenderer _MeshRenderer = null;


	private Vector3 _CameraPosition;

	void Awake () 
	{
		InitializeStuff();
		GenerateIntermediatePoints();
		GenerateMesh();
	}

	T GetOrAddComponent<T>() where T : UnityEngine.Component
	{
		T component = GetComponent<T>();

		if(component == null)
		{
			component = gameObject.AddComponent<T>();
		}

		return component;
	}

	void InitializeStuff()
	{
		if(_MeshRenderer == null)
		{
			_MeshRenderer = GetOrAddComponent<MeshRenderer>();
		}
		if(m_Material != null)
		{
			_MeshRenderer.sharedMaterial = m_Material;
		} else
		{
			_MeshRenderer.sharedMaterial = new Material(Shader.Find("Standard"));
		}
		if(_MeshFilter == null)
		{
			_MeshFilter = GetOrAddComponent<MeshFilter>();
		}
		
		_CameraPosition = Camera.main.transform.position;
		
		if(_Mesh == null)
		{
			_Mesh = new Mesh();
		}

		_LineHalfWidth = m_LineWidth * 0.5f;

		if(_IntermediatePoints == null)
		{
			_IntermediatePoints = new List<Vector3>();
		}

		if(_Vertices == null)
		{
			_Vertices = new List<Vector3>();					
		} else
		{
			_Vertices.Clear();
		}

		if(_Triangles == null)
		{
			_Triangles = new List<int>();
		} else
		{
			_Triangles.Clear();
		}
	}

	public void GenerateIntermediatePoints()
	{
		if(m_ControlPoints != null && m_ControlPoints.Length >= 4 && m_StepSize > 0.0f)
		{			
			float localT = 0f;
			float globalT = 0f;
			float totalT = m_ControlPoints.Length - 3;
			int pointId = 3;

			Vector3 p0 = m_ControlPoints[0].position;
			Vector3 p1 = m_ControlPoints[1].position;
			Vector3 p2 = m_ControlPoints[2].position;
			Vector3 p3 = m_ControlPoints[3].position;

			do
			{
				_IntermediatePoints.Add(GetPointOnSpline(localT, p0, p1, p2, p3));
				localT+=m_StepSize;

				if(localT >= 1f)
				{
					globalT += 1f;
					localT = localT - 1;
					if(pointId  < m_ControlPoints.Length - 1)
					{
						pointId++;
						p0 = p1;
						p1 = p2;
						p2 = p3;
						p3 = m_ControlPoints[pointId].position;					
					} 
				}
			} while(globalT < totalT);
			
			_IntermediatePoints.Add(GetPointOnSpline(1, p0, p1, p2, p3));				
		}
	}

	public void GenerateMesh()
	{
		if(_IntermediatePoints != null)
		{
			for(int pointId = 1; pointId < _IntermediatePoints.Count; ++pointId)
			{
				CreateMeshSegment(_IntermediatePoints[pointId - 1],
								  _IntermediatePoints[pointId]);
				
				_Mesh.vertices = _Vertices.ToArray();
				_Mesh.triangles = _Triangles.ToArray();
				_Mesh.RecalculateBounds();
				_Mesh.RecalculateNormals();
				_MeshFilter.sharedMesh = _Mesh;
			}	
		}
	}

	void CreateMeshSegment(Vector3 previousPoint, Vector3 currentPoint)
	{
		int idTop, idBottom;
		Vector3 segmentDirection = currentPoint - previousPoint;

		Vector3 normal = m_CustomNormal;
		if(m_FaceCamera)
		{ 
			normal = (_CameraPosition - previousPoint).normalized;
		}
		Vector3 widthDirection = Vector3.Cross(segmentDirection.normalized, normal);
		Vector3 halfWidthVector = widthDirection.normalized * _LineHalfWidth;

		if(_Vertices.Count > 1)
		{
			idTop = _Vertices.Count - 2;
			idBottom = _Vertices.Count - 1;
			if(m_AdjustCorner)
			{
				Vector3 newVertexTop = previousPoint + halfWidthVector;
				Vector3 newVertexBottom = previousPoint - halfWidthVector;

				Vector3	vertexTop = _Vertices[idTop];			
				Vector3	vertexBottom = _Vertices[idBottom];

				Vector3 midPointTop = vertexTop + (newVertexTop - vertexTop) * 0.5f;
				Vector3 midPointBottom = vertexBottom + (newVertexBottom - vertexBottom) * 0.5f;
				Vector3 midDirection = (midPointTop - midPointBottom).normalized;

				_Vertices[idTop]    = previousPoint + midDirection * _LineHalfWidth;
				_Vertices[idBottom] = previousPoint - midDirection * _LineHalfWidth;
			}	
		} else
		{
			_Vertices.Add(previousPoint + halfWidthVector);
			_Vertices.Add(previousPoint - halfWidthVector);
									
			idTop = _Vertices.Count - 2;
			idBottom = _Vertices.Count - 1;
		}
		
		_Vertices.Add(currentPoint + halfWidthVector);
		_Vertices.Add(currentPoint - halfWidthVector);
		
		AddQuad(idTop, idBottom, _Vertices.Count - 2, _Vertices.Count - 1);
	}

	void AddQuad(int id1, int id2, int id3, int id4)
	{
		AddTriangle(id1, id3, id2);
		AddTriangle(id2, id3, id4);
	}

	void AddTriangle(int id1, int id2, int id3)
	{
		_Triangles.Add(id1);
		_Triangles.Add(id2);
		_Triangles.Add(id3);		
	}
	
	Vector3 GetPointOnSpline(float t, Vector3 p0, Vector3 p1, Vector3 p2, Vector3 p3)
	{
		return 0.5f * ((2 * p1) +
 			  	(-p0 + p2) * t +
				(2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t +
				(-p0 + 3 * p1- 3 * p2 + p3) * t * t * t);
	}

	void OnDrawGizmos()
	{
		if(m_ControlPoints != null)
		{
			foreach(Transform point in m_ControlPoints)
			{
				Gizmos.DrawWireSphere(point.position, 0.5f);
			}

			if(m_ControlPoints.Length >= 4 && m_StepSize > 0.0f)
			{
				float localT = 0f;
				float globalT = 0f;
				float totalT = m_ControlPoints.Length - 3;
				int pointId = 3;

				Vector3 p0 = m_ControlPoints[0].position;
				Vector3 p1 = m_ControlPoints[1].position;
				Vector3 p2 = m_ControlPoints[2].position;
				Vector3 p3 = m_ControlPoints[3].position;

				Vector3 currentPoint = GetPointOnSpline(0, p0, p1, p2, p3);
				
				Vector3 previousPoint = currentPoint;
				localT+=m_StepSize;

				while(globalT < totalT)
				{
					currentPoint = GetPointOnSpline(localT, p0, p1, p2, p3);
																
					Gizmos.DrawLine(previousPoint, currentPoint);
					previousPoint = currentPoint;

					localT+=m_StepSize;

					if(localT >= 1f)
					{
						globalT += 1f;
						localT = localT - 1;
						if(pointId  < m_ControlPoints.Length - 1)
						{
							pointId++;
							p0 = p1;
							p1 = p2;
							p2 = p3;
							p3 = m_ControlPoints[pointId].position;					
						} 
					}
				}
				
				currentPoint = GetPointOnSpline(1, p0, p1, p2, p3);		
				Gizmos.DrawLine(previousPoint, currentPoint);																		
			}	
		}
	}
}
