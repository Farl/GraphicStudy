/**
 * by Farl
 **/

namespace SS
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using System;

    public class VisualTestCharacter : MonoBehaviour
    {
        private Transform _transform;
        public Transform cachedTransform
        {
            get { if (!_transform) _transform = transform; return _transform; }
        }
        public int group = 0;
        public Animator animator;
        public bool rangeAttack = true;

        public float moveToTime = 0.5f;
        public float moveToRatio = 0.5f;
        public float maxDegreesDelta = 45f;

        public float backToTime = 0.5f;
        public float jumpBackHeight = 2f;

        public float hitDelay = 0.2f;

        [NonSerialized]
        public bool IsAttacking = false;
        [NonSerialized]
        public Transform rangeAttackDummyTransform;

        private void Awake()
        {
            if (!animator)
                animator = GetComponent<Animator>();
        }

        public void Hit(float seconds)
        {
            StartCoroutine(HitCoroutine(seconds));
        }

        private IEnumerator HitCoroutine(float seconds)
        {
            yield return new WaitForSeconds(seconds);

            if (VisualTestRunner.Instance)
            {
                VisualTestRunner.Instance.AddHitEffect();
            }
            if (animator)
                animator.CrossFade("Hit", 0.1f);
        }

        public void Attack(VisualTestCharacter target, Action<VisualTestCharacter, VisualTestCharacter> onDone)
        {
            if (!Application.isPlaying)
                return;
            IsAttacking = true;
            if (rangeAttack)
            {
                StartCoroutine(RangeAttack(target, onDone));
            }
            else
            {
                StartCoroutine(MeleeAttack(target, onDone));
            }
        }

        public IEnumerator MeleeAttack(VisualTestCharacter target, Action<VisualTestCharacter, VisualTestCharacter> onDone)
        {
            Quaternion origRotation = cachedTransform.rotation;
            Vector3 origPosition = cachedTransform.position;

            Vector3 targetPosition = target.cachedTransform.position;
            Vector3 moveToPosition = Vector3.Lerp(origPosition, targetPosition, Mathf.Clamp01(moveToRatio));

            // Move to
            yield return MoveTo("Move", origPosition, moveToPosition, moveToTime);

            // Attack
            target.Hit(hitDelay);
            if (animator)
            {
                animator.CrossFade("Attack", 0.3f);
                yield return WaitForAnimation("Attack");

                animator.CrossFade("Idle", 0.3f);
            }

            // Back to
            yield return JumpBack("Fall", moveToPosition, origPosition, backToTime, jumpBackHeight);

            cachedTransform.rotation = origRotation;
            cachedTransform.position = origPosition;

            IsAttacking = false;
            onDone?.Invoke(this, target);
        }

        private IEnumerator MoveTo(string stateName, Vector3 fromPosition, Vector3 toPosition, float duration)
        {
            Quaternion moveToRotation = Quaternion.LookRotation(toPosition - fromPosition, Vector3.up);

            if (animator)
                animator.CrossFade(stateName, 0.3f);

            var time = 0f;
            var factor = 0f;
            duration = Mathf.Max(duration, 1e-5f);
            while (time < 30)   // timeout
            {
                factor = time / duration;
                factor = Mathf.Clamp01(factor);
                cachedTransform.rotation = Quaternion.RotateTowards(transform.rotation, moveToRotation, Time.deltaTime * maxDegreesDelta);
                var nextPos = Vector3.Lerp(fromPosition, toPosition, factor);
                cachedTransform.position = nextPos;
                if (factor >= 1)
                    break;
                yield return null;
                time += Time.deltaTime;
            }
        }
        private IEnumerator JumpBack(string stateName, Vector3 fromPosition, Vector3 toPosition, float duration, float height)
        {
            Quaternion moveToRotation = Quaternion.LookRotation(fromPosition - toPosition, Vector3.up);

            if (animator)
                animator.CrossFade(stateName, 0.3f);

            var time = 0f;
            var factor = 0f;
            duration = Mathf.Max(duration, 1e-5f);
            while (time < 30)   // timeout
            {
                factor = time / duration;
                factor = Mathf.Clamp01(factor);
                cachedTransform.rotation = Quaternion.RotateTowards(transform.rotation, moveToRotation, Time.deltaTime * maxDegreesDelta);
                var nextPos = Vector3.Lerp(fromPosition, toPosition, factor);
                var currHeight = Mathf.Sin(factor * Mathf.PI) * height;
                cachedTransform.position = nextPos + Vector3.up * currHeight;
                if (factor >= 1)
                    break;
                yield return null;
                time += Time.deltaTime;
            }
        }

        private IEnumerator WaitForAnimation(string stateName)
        {
            var time = 0f;
            yield return null;
            while (time < 30)   // timeout
            {
                var info = animator.GetCurrentAnimatorStateInfo(0);
                if (!animator.IsInTransition(0) && (!info.IsName(stateName) || info.normalizedTime >= 1))
                {
                    break;
                }
                yield return null;
                time += Time.deltaTime;
            }
        }

        public IEnumerator RangeAttack(VisualTestCharacter target, Action<VisualTestCharacter, VisualTestCharacter> onDone)
        {
            if (!rangeAttackDummyTransform)
            {
                var go = new GameObject("AttackDummy");
                rangeAttackDummyTransform = go.transform;
            }
            rangeAttackDummyTransform.position = Vector3.Lerp(cachedTransform.position, target.cachedTransform.position, 0.4f);

            //Debug.Log($"{name} -> {target.name}");
            target.Hit(hitDelay);
            if (animator)
            {
                animator.CrossFade("Attack", 0.3f);
                yield return WaitForAnimation("Attack");
            }
            IsAttacking = false;
            onDone?.Invoke(this, target);
        }
    }

}