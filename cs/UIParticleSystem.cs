/******************************************************************************
 *  作者 : <LIJIJIAN>
 *  版本 : 
 *  创建时间: 
 *  文件描述: UI 上的粒子控制
 *****************************************************************************/

using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 作者：<LIJIJIAN>
/// 说明：
/// 
/// </summary>
[ExecuteInEditMode]
public class UIParticleSystem : MonoBehaviour
{
    static Vector3[] wcs = new Vector3[4];
    private static MaterialPropertyBlock block;
    [SerializeField]
    private Renderer[] renderers;

#if UNITY_EDITOR && !BUILDING_PACK
    private void Awake()
    {
        ParticleSystem[] particleSystems = this.GetComponentsInChildren<ParticleSystem>(true);
        if (particleSystems.Length > 0)
        {
            renderers = new Renderer[particleSystems.Length];
            for (int i = 0; i < particleSystems.Length; ++i)
            {
                renderers[i] = particleSystems[i].GetComponent<Renderer>();
            }
        }
    }

    [ContextMenu("Fresh")][NoToLua]
    public void Fresh()
    {
        FreshClip();
    }
#endif

    private void OnEnable()
    {
        if(block != null)
            FreshClip();
    }

    private void Start()
    {
        if (block == null)
        {
            FreshClip();
        }
    }

    public void FreshClip()
    {
        if (block == null)
            block = new MaterialPropertyBlock();

        if (this.transform.parent != null)
        {
            RectTransform rect = null;
            Mask mask = this.GetComponentInParent<Mask>();
            if (mask == null)
            {
                RectMask2D mask2d = this.GetComponentInParent<RectMask2D>();
                if (mask2d != null)
                {
                    rect = mask2d.rectTransform;
                }
            }
            else
            {
                rect = mask.rectTransform;
            }

            SetClip(rect);
        }
    }

    private void SetClip(RectTransform rect)
    {
        Vector4 clipRect = Vector4.zero;
        float useClipRect = 0.0f;
        if (rect != null)
        {
            rect.GetWorldCorners(wcs);
            clipRect.Set(wcs[0].x, wcs[0].y, wcs[2].x, wcs[2].y);
            useClipRect = 1;
        }

        for (int i = 0; i < renderers.Length; ++i)
        {
            Renderer render = renderers[i];
            render.GetPropertyBlock(block);
            block.SetVector("_ClipRect", clipRect);
            block.SetFloat("_UseClipRect", useClipRect);
            render.SetPropertyBlock(block);
        }
    }


    public void FreshSortOrder(string layer, int order)
    {
        for (int i = 0; i < renderers.Length; ++i)
        {
            Renderer render = renderers[i];
            render.sortingLayerName = layer;
            render.sortingOrder = order;
        }
    }
}
