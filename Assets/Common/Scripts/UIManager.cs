using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class UIManager : MonoBehaviour {

    public GameObject levelButtonTemplate;
    public GameObject debugMenuGO;

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
    }

    // Use this for initialization
    void Start () {
		if (levelButtonTemplate)
        {
            Transform levelButtonRoot = levelButtonTemplate.transform.parent;

            levelButtonTemplate.SetActive(false);
            for (int i = 0; i < SceneManager.sceneCountInBuildSettings; i++)
            {
                if (i == 0)
                    continue;
                else
                {
                    GameObject go = Instantiate(levelButtonTemplate, levelButtonRoot);
                    go.SetActive(true);
                    var buildIndex = i;
                    Text t = go.GetComponentInChildren<Text>();
                    if (t)
                    {
                        t.text = buildIndex.ToString();
                    }
                    Button b = go.GetComponent<Button>();
                    if (b)
                    {
                        b.onClick.AddListener(() =>
                        {
                            SceneManager.LoadScene(buildIndex);
                        });
                    }
                }
            }

        }
	}

    public void ToggleDebugMenu()
    {
        debugMenuGO.SetActive(!debugMenuGO.activeSelf);
    }
}
