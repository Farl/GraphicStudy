/**
 * by Farl
 **/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/*
using SRDebugger;
using System.Reflection;
*/

namespace SS
{
    [ExecuteAlways]
    public class VisualTestRunner : MonoBehaviour
    {
        public static VisualTestRunner Instance;

        public bool showDebugInfo;
        public bool autoAttack = false;
        public float autoAttackInteval = 1;

        public List<GameObject> templates = new List<GameObject>();
        [HideInInspector]
        public List<Transform> heroTransforms = new List<Transform>();
        [HideInInspector]
        public List<VisualTestCharacter> characters = new List<VisualTestCharacter>();
        [HideInInspector]
        public List<VisualTestCharacter> activeCharacters = new List<VisualTestCharacter>();

        private Transform cameraTransform;

        [Header("Layout")]
        public Vector2 groupDiff = Vector2.one;
        public Vector2 groupGrid = Vector2.one;
        public int heroCount = 3;
        public int gridSize = 3;
        public int currentCharacterIdx = 0;

        [Header("Camera")]
        public Camera mainCamera;
        public CameraType previewType;
        public CameraParameter normalCam;
        public CameraParameter attackCam;
        public CameraParameter rangeAttackCam;
        public bool useCameraLerp = true;
        public float cameraLerpFactor = 10f;
        public float cameraMaxDeltaDistance = 20f;
        public float cameraMaxDeltaFOV = 180f;
        public bool isAttackCameraCut = false;
        public CameraEffect normalCamEffect;
        public CameraEffect hitCamEffect;

        private LookAtData targetLookAt;
        private bool isCameraCut = false;
        private List<CameraEffect> effects = new List<CameraEffect>();
        private bool isDirty;

        private Transform _transform;
        private Transform cachedTransform
        {
            get
            {
                if (_transform == null)
                    _transform = transform;
                return _transform;
            }
        }

        public enum CameraType
        {
            Normal,
            Attack,
            RangeAttack,
        }

        [System.Serializable]
        public class CameraEffect
        {
            public Vector3 cameraPositionOffset
            {
                get
                {
                    var up = Vector3.up;
                    var left = Vector3.Cross(up, axis).normalized;
                    var posOffset = offset.x * left + offset.y * up;
                    return posOffset + Mathf.Sin(value) * distance.y * up + Mathf.Cos(value) * distance.x * left;
                }
            }

            [System.NonSerialized]
            public Vector3 axis;
            [System.NonSerialized]
            public float weight = 1;

            public Vector2 offset = Vector2.zero;
            public Vector2 distance = Vector2.one;
            public float speed = 1;

            private float value;

            public void Update()
            {
                value += speed * Time.deltaTime;
            }
        }

        private class LookAtData
        {
            public Vector3 position;
            public Vector3 targetPosition;
            public float fov;

            public void SetTargets_Average(List<Vector3> targets)
            {
                if (targets == null || targets.Count <= 0)
                    return;
                var origForward = forward;

                // Average method
                var average = Vector3.zero;
                foreach (var v in targets)
                {
                    average += v;
                }
                average /= (float)targets.Count;
                targetPosition = average;
                position = targetPosition - origForward;
            }
            public void SetTargets_Bounds(List<Vector3> targets)
            {
                if (targets == null || targets.Count <= 0)
                    return;
                var origForward = forward;
                var localToWorld = Matrix4x4.LookAt(position, targetPosition, Vector3.up);
                var worldToLocal = localToWorld.inverse;
                var isInit = false;

                // Project plane method
                Plane plane = new Plane(origForward, position);
                Bounds bounds = new Bounds();
                var maxD = 0f;
                foreach (var v in targets)
                {
                    var wpp = plane.ClosestPointOnPlane(v);
                    var d = plane.GetDistanceToPoint(v);
                    if (d > maxD)
                        maxD = d;
                    var lpp = worldToLocal * wpp;
                    var b = new Bounds(lpp, Vector3.one);
                    if (!isInit)
                    {
                        bounds = b;
                        isInit = true;
                    }
                    else
                    {
                        bounds.Encapsulate(b);
                    }
                }
                if (isInit)
                {
                    var p = localToWorld * bounds.center;
                    position = p;
                    targetPosition = position + origForward.normalized * maxD;
                }
                Debug.DrawLine(position, position + Vector3.up, Color.white);
                Debug.DrawLine(position, targetPosition, Color.blue);
            }

            public void SetTargetList_LocalBounds(List<Vector3> targets)
            {
                if (targets == null || targets.Count <= 0)
                    return;

                var origForward = forward;
                var localToWorld = Matrix4x4.LookAt(position, targetPosition, Vector3.up);
                var worldToLocal = localToWorld.inverse;
                var isInit = false;

                // Local coordinate bounds
                Bounds bounds = new Bounds();
                foreach (var v in targets)
                {
                    var localV = worldToLocal * v;
                    var b = new Bounds(localV, Vector3.one);
                    if (isInit == false)
                    {
                        bounds = b;
                        isInit = true;
                    }
                    else
                    {
                        bounds.Encapsulate(b);
                    }
                }
                if (isInit)
                {
                    targetPosition = localToWorld * bounds.center;
                    position = targetPosition - origForward;
                }
            }

            public void SetTargets_FixPosition(List<Vector3> targets)
            {
                if (targets == null || targets.Count <= 0)
                    return;

                // Fix distance to contain every targets
                var range = (targets.Count > 2)? 1: 0.9f;
                var minFOV = range * fov * Mathf.Min(Screen.width, Screen.height) / (float)Screen.height;
                var maxDistance = (position - targetPosition).magnitude;
                var newPos = position;
                var origPosition = position;
                //Debug.DrawLine(position, targetPosition, Color.magenta);
                foreach (var v in targets)
                {
                    var projectPos = position + Vector3.Project(v - position, forward);
                    var l = (projectPos - v).magnitude;
                    var m = l / Mathf.Tan(minFOV * 0.5f * Mathf.Deg2Rad);

                    var np = projectPos - forward.normalized * m;
                    var d = (np - targetPosition).magnitude;
                    if (d >= maxDistance)
                    {
                        maxDistance = d;
                        newPos = np;
                    }

                    //Debug.DrawLine(v, projectPos, Color.cyan);
                    //Debug.DrawLine(v, position, Color.yellow);
                    //Debug.DrawLine(v, np, Color.red);
                }
                position = newPos;
                //Debug.DrawLine(position, origPosition, Color.blue);
            }

            public Vector3 forward
            {
                get { return targetPosition - position; }
            }
            public LookAtData(Vector3 position, Vector3 targetPosition, float fov)
            {
                this.position = position;
                this.targetPosition = targetPosition;
                this.fov = fov;
            }
            public LookAtData(Vector3 position, Quaternion rotation, float fov, float distance = 1f)
            {
                this.position = position;
                this.targetPosition = rotation * (Vector3.forward * distance);
                this.fov = fov;
            }

            public void Setup(Transform t, Camera camera)
            {
                if (t)
                {
                    t.position = position;
                    t.LookAt(targetPosition);
                }
                if (camera != null)
                    camera.fieldOfView = fov;
            }

            public void Lerp(LookAtData b, float time)
            {
                this.position = Vector3.Lerp(this.position, b.position, time);
                this.targetPosition = Vector3.Lerp(this.targetPosition, b.targetPosition, time);
                this.fov = Mathf.Lerp(this.fov, b.fov, time);
            }

            public void Towards(LookAtData b, float maxDistanceDelta, float maxFOVDelta)
            {
                this.position = Vector3.MoveTowards(this.position, b.position, maxDistanceDelta);
                this.targetPosition = Vector3.MoveTowards(this.targetPosition, b.targetPosition, maxDistanceDelta);
                this.fov = Mathf.MoveTowards(this.fov, fov, maxFOVDelta);
            }
        }

        [System.Serializable]
        public class CameraParameter
        {
            public Vector3 targetOffset = new Vector3(0, 1, 0);
            public Vector3 cameraEulerAngles = new Vector3(0, 0, 0);
            public Vector3 cameraOffset = Vector3.forward;
            [Range(0f, 360f)]
            public float fov = 60;
        }

        #region Public
        public void AddHitEffect()
        {
            if (!Application.isPlaying || Instance != this)
                return;
            StartCoroutine(HitCoroutine());
        }

        private IEnumerator HitCoroutine()
        {
            var fx = hitCamEffect;
            effects.Add(fx);
            var duration = 0.15f;
            var time = duration;
            while (time >= 0)
            {
                fx.weight = 1 - time / duration;
                yield return null;
                time -= Time.deltaTime;
            }
            fx.weight = 1;
            time = duration;
            while (time >= 0)
            {
                fx.weight = time / duration;
                yield return null;
                time -= Time.deltaTime;
            }
            effects.Remove(fx);
        }
        #endregion

        [ContextMenu("Spawn random")]
        private void SpawnRandom()
        {
            Spawn(true);
            ShowRandom();
        }

        [ContextMenu("Spawn first")]
        private void SpawnFirst()
        {
            Spawn(false);
            ShowRandom();
        }

        [ContextMenu("Show All")]
        private void ShowAll()
        {
            isDirty = true;
            activeCharacters.Clear();
            foreach (var t in heroTransforms)
            {
                if (t)
                    t.gameObject.SetActive(true);
            }
            foreach (var c in characters)
            {
                if (c)
                {
                    activeCharacters.Add(c);
                }
            }
        }

        [ContextMenu("Show Random")]
        private void ShowRandom()
        {
            if (heroTransforms.Count < 2 * gridSize * gridSize)
                return;

            isDirty = true;
            activeCharacters.Clear();

            var list = new List<int>();
            var activeList = new List<int>();
            for (int i = 0; i < 2; i++)
            {
                list.Clear();
                activeList.Clear();

                for (var l = 0; l < gridSize * gridSize; l++)
                {
                    list.Add(l);
                }
                for (var r = 0; r < heroCount; r++)
                {
                    var rand = Random.Range(0, list.Count);
                    var pick = list[rand];
                    activeList.Add(pick);
                    list.Remove(pick);
                }

                if (showDebugInfo)
                {
                    var debug = $"{i}: ";
                    foreach (var a in activeList)
                        debug += $"{a} ";
                    Debug.Log($"{debug}");
                }

                for (int u = 0; u < gridSize; u++)
                {
                    for (int v = 0; v < gridSize; v++)
                    {
                        var id = v + gridSize * u + gridSize * gridSize * i;
                        var id2 = v + gridSize * u;

                        var isActive = activeList.Contains(id2);
                        if (heroTransforms[id])
                            heroTransforms[id].gameObject.SetActive(isActive);
                        if (isActive)
                            activeCharacters.Add(characters[id]);
                    }
                }
            }

        }

        private VisualTestCharacter GetCharacter(int idx)
        {
            if (idx >= 0 && idx < activeCharacters.Count)
            {
                return activeCharacters[idx];
            }
            return null;
        }

        private VisualTestCharacter CurrentCharacter()
        {
            return GetCharacter(currentCharacterIdx);
        }

        private VisualTestCharacter CurrentTargetCharacter()
        {
            var count = activeCharacters.Count / 2;

            if (count <= 0)
                return null;

            //var idx = Random.Range(0, count);
            var idx = (currentCharacterIdx + 1) % count;
            var targetIdx = ((currentCharacterIdx >= count)? 0: count) + idx;
            //var targetIdx = (currentCharacterIdx + count) % (2 * count);
            return GetCharacter(targetIdx);
        }

        [ContextMenu("Attack")]
        private void Attack()
        {
            var count = activeCharacters.Count / 2;
            var ch = CurrentCharacter();
            var targetCh = CurrentTargetCharacter();
            if (ch && targetCh && !ch.IsAttacking)
            {
                ch.Attack(targetCh, (ch, targetCh) =>
                {
                    currentCharacterIdx++;
                    currentCharacterIdx %= count * 2;
                    if (autoAttack)
                        Invoke("Attack", autoAttackInteval);
                });
                isCameraCut = isAttackCameraCut;
            }
        }

        private void Spawn(bool random = false)
        {
            isDirty = true;
            currentCharacterIdx = 0;

            if (heroTransforms == null)
                heroTransforms = new List<Transform>();

            // Clear
            foreach (var t in heroTransforms)
            {
                if (t == null)
                    continue;
                if (Application.isPlaying)
                    Destroy(t.gameObject);
                else
                    DestroyImmediate(t.gameObject);
            }
            heroTransforms.Clear();
            characters.Clear();

            if (templates.Count <= 0)
                return;

            for (int i = 0; i < 2; i++)
            {
                for (int u = 0; u < gridSize; u++)
                {
                    for (int v = 0; v < gridSize; v++)
                    {
                        var idx = (random) ? Random.Range(0, templates.Count) : 0;
                        var template = templates[idx];
                        if (template)
                        {
                            var go = GameObject.Instantiate(template);
                            heroTransforms.Add(go.transform);

                            VisualTestCharacter ch = go.GetComponent<VisualTestCharacter>();
                            characters.Add(ch);
                            if (ch)
                            {
                                ch.group = i;
                            }
                        }
                    }
                }
            }
        }

        private object[] Test(object input)
        {
            Debug.Log(input);
            return null;
        }

        private float _test = 0.5f;
        public float test
        {
            get { return _test; }
            set { _test = value; Debug.Log(value); }
        }

        /*
        private XPoseDetector _xposDetector;
        */

        protected virtual void OnStart()
        {
            /*
            _xposDetector = gameObject.AddComponent<XPoseDetector>();
            SRDebug.Init();

            SRDebug.Instance.AddOption(
                new OptionDefinition("Attack", "Visaul Test", 0,
                new SRF.Helpers.MethodReference((objs) => {
                    Attack();
                    return null;
                }
            )));

            SRDebug.Instance.AddOption(
                new OptionDefinition("Spawn First", "Visaul Test", 0,
                new SRF.Helpers.MethodReference((objs) => {
                    SpawnFirst();
                    return null;
                }
            )));

            SRDebug.Instance.AddOption(
                new OptionDefinition("Spawn Random", "Visaul Test", 0,
                new SRF.Helpers.MethodReference((objs) => {
                    SpawnRandom();
                    return null;
                }
            )));

            PropertyInfo propertyInfo = this.GetType().GetProperty("test", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            SRF.Helpers.PropertyReference propertyReference = new SRF.Helpers.PropertyReference(this, propertyInfo);
            var option = new OptionDefinition("c", "d", 0, propertyReference);
            SRDebug.Instance.AddOption(option);


            propertyReference = new SRF.Helpers.PropertyReference(typeof(float), () => { return test; }, (v) => { test = (float)v; }, new System.Attribute[] { });
            option = new OptionDefinition("e", "d", 0, propertyReference);
            SRDebug.Instance.AddOption(option);
            */
        }

        protected virtual void OnUpdate()
        {
            
            /*
            if (Application.isPlaying && _xposDetector && _xposDetector.IsTriggered)
            {
                SRDebug.Instance.ShowDebugPanel();
                _xposDetector.ResetTriggered();
            }
            */
        }

        // Start is called before the first frame update
        void Start()
        {
            if (Application.isPlaying)
            {
                OnStart();
            }

            if (mainCamera == null)
                mainCamera = Camera.main;

            if (mainCamera && cameraTransform == null)
                cameraTransform = mainCamera.transform;
        }

        private float GridFix(float value)
        {
            if (gridSize <= 0)
                return value;
            return ((value / (gridSize - 1)) * 2 - 1);
        }

        // Update is called once per frame
        void Update()
        {
            OnUpdate();
            if (Application.isPlaying)
            {

                if (Input.GetKeyDown(KeyCode.A))
                {
                    Attack();
                }
            }

            UpdateCamera();

            if (isDirty)
            {
                UpdatePosition();
                isDirty = false;
            }
        }

        private void UpdatePosition()
        {
            if (heroTransforms == null || heroTransforms.Count < gridSize * gridSize * 2)
                return;

            for (int i = 0; i < 2; i++)
            {
                var sign = i * 2 - 1;

                Vector3 groupPos = cachedTransform.TransformPoint(sign * new Vector3(groupDiff.x, 0, groupDiff.y));

                for (int u = 0; u < gridSize; u++)
                {
                    for (int v = 0; v < gridSize; v++)
                    {
                        var g = new Vector3(GridFix(u) * groupGrid.x, 0, GridFix(v) * groupGrid.y);

                        g = cachedTransform.TransformVector(g) + groupPos;

                        var id = v + gridSize * u + gridSize * gridSize * i;

                        if (heroTransforms[id] != null)
                        {
                            heroTransforms[id].position = g;

                            heroTransforms[id].forward = cachedTransform.position - groupPos;
                        }
                    }
                }
            }
        }

        private LookAtData CurrentLookAtData(CameraParameter parameter, Transform targetTransform)
        {
            var targetForward = cachedTransform.TransformDirection(parameter.cameraOffset);
            targetForward = Quaternion.Euler(parameter.cameraEulerAngles) * targetForward;
            var targetPos = targetTransform.position + parameter.targetOffset;
            var targetFOV = parameter.fov;
            var cameraPos = targetPos - targetForward;

            return new LookAtData(cameraPos, targetPos, targetFOV);
        }

        private void UpdateCamera()
        {
            if (cameraTransform == null)
                return;

            var cameraParameter = normalCam;
            var targetTransform = cachedTransform;
            List<Vector3> targetList = null;
            if (Application.isPlaying)
            {
                var ch = CurrentCharacter();
                if (ch && ch.group == 0 && ch.IsAttacking)
                {
                    if (ch.rangeAttack)
                    {
                        cameraParameter = rangeAttackCam;
                        targetTransform = ch.rangeAttackDummyTransform;
                        targetList = new List<Vector3>();
                        var targetCh = CurrentTargetCharacter();
                        if (targetCh)
                        {
                            targetList.Add(ch.cachedTransform.position);
                            targetList.Add(targetCh.cachedTransform.position);
                        }
                    }
                    else
                    {
                        cameraParameter = attackCam;
                        targetTransform = ch.cachedTransform;
                    }
                }
                else
                {
                    /*
                    targetList = new List<Vector3>();
                    foreach (var ac in activeCharacters)
                    {
                        targetList.Add(ac.cachedTransform.position);
                    }
                    */
                }
            }
            else
            {
                var ch = CurrentCharacter();
                var targetCh = CurrentTargetCharacter();
                switch (previewType)
                {
                    default:
                    case CameraType.Normal:
                        cameraParameter = normalCam;
                        targetTransform = cachedTransform;
                        break;
                    case CameraType.Attack:
                        cameraParameter = attackCam;
                        if (ch)
                            targetTransform = ch.cachedTransform;
                        break;
                    case CameraType.RangeAttack:
                        cameraParameter = rangeAttackCam;
                        targetList = new List<Vector3>();
                        if (ch)
                        {
                            targetTransform = ch.cachedTransform;
                            targetList.Add(ch.cachedTransform.position);
                        }
                        if (targetCh)
                        {
                            targetList.Add(targetCh.cachedTransform.position);
                        }
                        break;
                }
            }

            var lookAt = CurrentLookAtData(cameraParameter, targetTransform);
            if (targetList != null && targetList.Count > 0)
            {
                lookAt.SetTargets_Average(targetList);
                lookAt.SetTargets_FixPosition(targetList);
            }

            //Debug.DrawLine(lookAt.position, lookAt.targetPosition);

            if (!Application.isPlaying)
            {
                lookAt.Setup(cameraTransform, mainCamera);
            }
            else
            {
                // Apply camera effects
                normalCamEffect.axis = lookAt.forward;
                normalCamEffect.Update();
                lookAt.position += normalCamEffect.cameraPositionOffset;

                foreach (var fx in effects)
                {
                    fx.axis = lookAt.forward;
                    fx.Update();
                    lookAt.position += fx.cameraPositionOffset;
                }

                if (targetLookAt == null || isCameraCut)
                {
                    targetLookAt = lookAt;
                    isCameraCut = false;
                }
                else
                {
                    if (useCameraLerp)
                        targetLookAt.Lerp(lookAt, cameraLerpFactor * Time.deltaTime);
                    else
                        targetLookAt.Towards(lookAt, cameraMaxDeltaDistance * Time.deltaTime, cameraMaxDeltaFOV * Time.deltaTime);
                }

                targetLookAt.Setup(cameraTransform, mainCamera);
            }
        }

        private void OnValidate()
        {
            isDirty = true;
        }

        private void Awake()
        {
            if (Instance == null)
            {
                Instance = this;
                if (autoAttack)
                {
                    Invoke("Attack", autoAttackInteval);
                }
            }
        }

        private void OnDestroy()
        {
            if (Instance == this)
                Instance = null;
        }
    }

}