using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static WireCubeSpawner;

public class WireCubeSpawner : MonoBehaviour
{
    public Emitter template;
    public Vector3 positionMin;
    public Vector3 positionMax;
    public Vector3 eulerAnglesMin;
    public Vector3 eulerAnglesMax;

    [System.SerializableAttribute]
    public class Emitter
    {
        public Color colorMin;
        public Color colorMax;
        [System.NonSerialized]
        public Color color;

        [System.NonSerialized]
        public int index = 0;
        [System.NonSerialized]
        public ParticleSystem particleSystem;
        [System.NonSerialized]
        public Vector3 position;
        [System.NonSerialized]
        public Vector3 eulerAngles;
        
        public GameObject go;
        [System.NonSerialized]
        public Transform transform;

        public float lifetime = 20;

        public Vector3 rotationOverLifetimeMin = new Vector3(0, 0, 10);
        public Vector3 rotationOverLifetimeMax = new Vector3(0, 0, 30);

        [System.NonSerialized]
        public float timer;

        public Vector3 frequence = new Vector3(0, 0.1f, 0.2f);
        public Vector3 amplitude = new Vector3(1, 1, 1);

        public Vector2 speedMinMax = Vector2.one;
        [System.NonSerialized]
        public float speed = 1;

        public float timeOffset = 10;

        private float deleteTimer;

        private GameObject detectorGO;
        private WireCubeDetector detector;

        public float pressScale = 1.002f;


        private bool firstVisible = false;
        public bool IsVisible
        {
            get
            {
                float border = 40f;

                var cam = Camera.main;
                var screenPos = cam.WorldToScreenPoint(transform.position);
                var screenSize = new Vector2(Screen.width, Screen.height);
                var screenCenter = screenSize / 2.0f;
                var screenDiff = (Vector2)(screenPos) - screenCenter;
                bool isOutOfRange = Mathf.Abs(screenDiff.x) > screenSize.x / 2.0f + border || Mathf.Abs(screenDiff.y) > screenSize.y / 2.0f + border;

                // Screen position detect
                if (firstVisible)
                {
                    return !isOutOfRange;
                }
                else
                {
                    if (!isOutOfRange)
                        firstVisible = true;
                    return true;
                }
            }
        }

        public float random(float t)
        {
            return (Mathf.Cos(t) + Mathf.Cos(t * 1.3f + 1.3f) + Mathf.Cos(t * 1.4f + 1.4f)) / 3.0f;
        }

        public void Update()
        {
            if (timer >= lifetime)
            {
                UpdateDelete();
                return;
            }
            var t = timer + index * timeOffset;
            Vector3 movement = new Vector3(amplitude.x, amplitude.y * random((t) * frequence.y), amplitude.z * random((t) * frequence.z));
            var newPos = position + movement * speed * Time.deltaTime;


            var up = Quaternion.AngleAxis(45f * Time.deltaTime, transform.forward) * transform.up;
            transform.rotation = Quaternion.RotateTowards(transform.rotation, Quaternion.LookRotation(newPos - position, up), 180f * Time.deltaTime);

            if (particleSystem)
            {
                var main = particleSystem.main;
                main.startRotation3D = true;
                main.startRotationX = transform.eulerAngles.x * Mathf.Deg2Rad;
                main.startRotationY = transform.eulerAngles.y * Mathf.Deg2Rad;
                main.startRotationZ = transform.eulerAngles.z * Mathf.Deg2Rad;
            }

            position = newPos;
            transform.position = position;

            timer += Time.deltaTime;

            if (timer >= lifetime)
            {
                StartDelete();
            }
        }

        public Emitter(GameObject gameObject)
        {
            go = gameObject;
            transform = gameObject.transform;

            particleSystem = gameObject.GetComponentInChildren<ParticleSystem>();
            if (particleSystem)
            {
            }

            detectorGO = new GameObject($"{gameObject.name}.Detector");
            detector = detectorGO.AddComponent<WireCubeDetector>();
            detector.onPressed += OnPressed;
            detector.trackTransform = transform;

            transform.eulerAngles = eulerAngles;
            transform.position = position;
        }

        // TODO
        private void OnPressed(RaycastHit hitInfo)
        {
            if (particleSystem)
            {
                var main = particleSystem.main;

                var count = particleSystem.particleCount;
                ParticleSystem.Particle[] ps = new ParticleSystem.Particle[count];
                var nCount = particleSystem.GetParticles(ps, count);
                for (var i = 0; i < nCount; i++)
                {
                    var d = (hitInfo.point - ps[i].position).magnitude;
                    if (d < 1)
                    {
                        var color32 = ps[i].GetCurrentColor(particleSystem);
                        ps[i].startColor = Color32.Lerp(Color.white, color, d);

                        ps[i].startSize3D = ps[i].startSize3D * pressScale;
                    }
                }
                particleSystem.SetParticles(ps, nCount);
            }
        }

        public void Init()
        {
            if (particleSystem)
            {
                var mod = particleSystem.rotationOverLifetime;
                mod.z = Random.Range(rotationOverLifetimeMin.x * Mathf.Deg2Rad, rotationOverLifetimeMax.x * Mathf.Deg2Rad) * (Random.Range(0, 2) > 0 ? 1 : -1);
                mod.z = Random.Range(rotationOverLifetimeMin.y * Mathf.Deg2Rad, rotationOverLifetimeMax.y * Mathf.Deg2Rad) * (Random.Range(0, 2) > 0 ? 1 : -1);
                mod.z = Random.Range(rotationOverLifetimeMin.z * Mathf.Deg2Rad, rotationOverLifetimeMax.z * Mathf.Deg2Rad) * (Random.Range(0, 2) > 0 ? 1 : -1);

                var main = particleSystem.main;
                main.startRotation3D = true;
                main.startRotationX = transform.eulerAngles.x * Mathf.Deg2Rad;
                main.startRotationY = transform.eulerAngles.y * Mathf.Deg2Rad;
                main.startRotationZ = transform.eulerAngles.z * Mathf.Deg2Rad;

                main.startColor = color;
            }
        }

        public void StartDelete()
        {
            timer = lifetime;
            deleteTimer = 0;
            if (particleSystem)
            {
                var main = particleSystem.main;
                deleteTimer = main.startLifetime.constant;
            }
        }

        public void UpdateDelete()
        {
            if (particleSystem && go)
            {
                if (particleSystem.particleCount == 0)
                {
                    Delete();
                }
            }
            deleteTimer -= Time.deltaTime;
        }

        public bool IsOver => go == null;

        public void Delete()
        {
            Destroy(go);
            Destroy(detectorGO);
        }

    }

    public bool isPlaying = true;
    public int emitterCount = 2;
    private int count = 0;

    private List<Emitter> emitters = new List<Emitter>();
    // Start is called before the first frame update
    IEnumerator Start()
    {
        List<Emitter> removeList = new List<Emitter>();
        while (isPlaying)
        {
            var cam = Camera.main;
            var mouseButton = Input.GetMouseButton(0);
            if (mouseButton)
            {
                var ray = cam.ScreenPointToRay(Input.mousePosition);
                var hitInfos = Physics.RaycastAll(ray, 1000);
                if (hitInfos != null)
                {
                    foreach(var hitInfo in hitInfos)
                    {
                        var d = hitInfo.collider.GetComponentInParent<WireCubeDetector>();
                        if (d != null)
                        {
                            d.onPressed?.Invoke(hitInfo);
                        }
                    }
                }
            }

            while (emitters.Count < emitterCount)
            {
                var e = new Emitter(GameObject.Instantiate(template.go))
                {
                    amplitude = template.amplitude,
                    frequence = template.frequence,
                    lifetime = template.lifetime,
                    position = new Vector3(Random.Range(positionMin.x, positionMax.x), Random.Range(positionMin.y, positionMax.y), Random.Range(positionMin.z, positionMax.z)),
                    eulerAngles = new Vector3(Random.Range(eulerAnglesMin.x, eulerAnglesMax.x), Random.Range(eulerAnglesMin.y, eulerAnglesMax.y), Random.Range(eulerAnglesMin.z, eulerAnglesMax.z)),
                    speed = Random.Range(template.speedMinMax.x, template.speedMinMax.y),
                    timeOffset = template.timeOffset,
                    index = count,
                    color = Color.Lerp(template.colorMin, template.colorMax, Random.Range(0f, 1f)),
                    pressScale = template.pressScale
                };

                e.Init();
                count++;
                emitters.Add(e);
            }

            removeList.Clear();
            bool isAllInvisible = true;
            foreach (var emitter in emitters)
            {
                // Simulation
                emitter.Update();
                if (emitter.IsOver)
                {
                    removeList.Add(emitter);
                }
                else
                {
                    if (emitter.IsVisible)
                    {
                        isAllInvisible = false;
                    }
                }
            }

            if (isAllInvisible)
            {
                foreach (var emitter in emitters)
                {
                    emitter.StartDelete();
                }
            }

            foreach (var emitter in removeList)
            {
                emitters.Remove(emitter);
            }
            yield return null;
        }
        yield break;
    }

    private void OnValidate()
    {
        while (emitters.Count > 0)
        {
            emitters[0].Delete();
            emitters.RemoveAt(0);
        }
    }

    private void OnDrawGizmos()
    {
        var diff = positionMax - positionMin;
        Gizmos.DrawCube(((positionMax + positionMin) / 2f), new Vector3(Mathf.Abs(diff.x), Mathf.Abs(diff.y), Mathf.Abs(diff.z)));
    }
}
