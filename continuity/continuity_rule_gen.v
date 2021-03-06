(*

  Copyright 2014 Cornell University
  Copyright 2015 Cornell University
  Copyright 2016 Cornell University
  Copyright 2017 Cornell University

  This file is part of VPrl (the Verified Nuprl project).

  VPrl is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  VPrl is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with VPrl.  If not, see <http://www.gnu.org/licenses/>.


  Websites: http://nuprl.org/html/verification/
            http://nuprl.org/html/Nuprl2Coq
            https://github.com/vrahli/NuprlInCoq

  Authors: Vincent Rahli

 *)


Require Export continuity_type.
Require Export continuity_type_v2.
Require Export sequents2.
Require Export sequents_tacs.
Require Export per_props_squash.
Require Export per_props_isect.
Require Export lift_lsubst_tacs.


Definition simple_eq_typec {o} lib (T : @NTerm o) :=
  forall w s c, simple_eq_type lib (lsubstc T w s c).

Definition rule_continuity {o}
           (F f T : @NTerm o)
           (H : barehypotheses)
           (i : nat) :=
    mk_rule
      (mk_baresequent H (mk_conclax (mk_squash (continuous_type_v2 F f T))))
      [
        mk_baresequent H (mk_conclax (mk_member F (mk_fun (mk_fun mk_int T) mk_int))),
        mk_baresequent H (mk_conclax (mk_member f (mk_fun mk_int T))),
        mk_baresequent H (mk_conclax (mk_member T (mk_uni i)))
      ]
      [].

Lemma rule_continuity_true3 {p} :
  forall lib
         (F f T : NTerm)
         (H : @barehypotheses p)
         (i : nat)
         (se : simple_eq_typec lib T),
    rule_true3 lib (rule_continuity
                      F f T
                      H i).
Proof.
  unfold rule_continuity, rule_true3, wf_bseq, closed_type_baresequent, closed_extract_baresequent; simpl.
  intros.
  clear cargs.

  (* We prove the well-formedness of things *)
  destseq; allsimpl.
  dLin_hyp.
  rename Hyp into hyp1.
  rename Hyp0 into hyp2.
  rename Hyp1 into hyp3.
  destruct hyp1 as [wc1 hyp1].
  destruct hyp2 as [wc2 hyp2].
  destruct hyp3 as [wc3 hyp3].
  destseq; allsimpl; proof_irr; GC.
  unfold closed_extract; simpl.

  assert (wf_csequent ((H) ||- (mk_conclax (mk_squash (continuous_type_v2 F f T))))) as wfs.
  { wfseq. }

  exists wfs.

  (* We prove some simple facts on our sequents *)
  (* done with proving these simple facts *)

  vr_seq_true.

  vr_seq_true in hyp1.
  pose proof (hyp1 s1 s2 eqh sim) as h; exrepnd; clear hyp1.

  vr_seq_true in hyp2.
  pose proof (hyp2 s1 s2 eqh sim) as k; exrepnd; clear hyp2.

  vr_seq_true in hyp3.
  pose proof (hyp3 s1 s2 eqh sim) as q; exrepnd; clear hyp3.

  lsubst_tac.

  apply equality_in_member in q1; repnd.
  clear q2 q3.
  apply member_in_uni in q1; auto.
  apply tequality_in_uni_implies_tequality in q0; auto;[].

  assert ((newvarlst [F, f, T]
           <> newvarlst
                [F, f, T, mk_var (newvarlst [F, f, T]),
                 mk_var (newvarlst [F, f, T, mk_var (newvarlst [F, f, T])])])
            # (newvarlst [F, f, T]
               <> newvarlst [F, f, T, mk_var (newvarlst [F, f, T])])
            # (newvarlst [F, f, T, mk_var (newvarlst [F, f, T])]
               <> newvarlst
                    [F, f, T, mk_var (newvarlst [F, f, T]),
                     mk_var (newvarlst [F, f, T, mk_var (newvarlst [F, f, T])])])
            # (!LIn (newvarlst
                       [F, f, T, mk_var (newvarlst [F, f, T]),
                        mk_var (newvarlst [F, f, T, mk_var (newvarlst [F, f, T])])])
                (free_vars f))
            # (!LIn (newvarlst [F, f, T, mk_var (newvarlst [F, f, T])]) (free_vars f))
            # (!LIn (newvarlst [F, f, T]) (free_vars f))
            # (!LIn (newvarlst
                       [F, f, T, mk_var (newvarlst [F, f, T]),
                        mk_var (newvarlst [F, f, T, mk_var (newvarlst [F, f, T])])])
                (free_vars F))
            # (!LIn (newvarlst [F, f, T, mk_var (newvarlst [F, f, T])]) (free_vars F))
            # (!LIn (newvarlst [F, f, T]) (free_vars F))
            # (!LIn (newvarlst
                       [F, f, T, mk_var (newvarlst [F, f, T]),
                        mk_var (newvarlst [F, f, T, mk_var (newvarlst [F, f, T])])])
                (free_vars T))
            # (!LIn (newvarlst [F, f, T, mk_var (newvarlst [F, f, T])]) (free_vars T))
            # (!LIn (newvarlst [F, f, T]) (free_vars T))
         ) as d.
  { repeat gen_newvar.
    repeat get_newvar_prop.
    allsimpl; allrw in_app_iff.
    allrw not_over_or; sp. }
  repnd.

  prove_and teq.

  - apply tequality_mkc_squash.
    allrw @member_eq.
    allrw <- @member_member_iff.
    allrw @tequality_mkc_member_sp; repnd.
    allrw @fold_equorsq.

    unfold continuous_type_v2, continuous_type_aux_v2; simpl.
    lsubst_tac.

    apply tequality_product; dands; eauto with slow.

    { allrw @lsubstc_mkc_tnat.
      apply type_tnat. }

    introv e1.
    repeat substc_lsubstc_vars3.
    lsubst_tac.

    apply tequality_isect; dands.

    { lsubst_tac.
      apply tequality_fun; dands; tcsp.
      apply tequality_int. }

    introv e2.

    repeat substc_lsubstc_vars3.
    repeat one_lift_lsubst_concl.
    apply tequality_mkc_ufun; dands.

    { unfold agree_upto_b_type_v2.
      repeat one_lift_lsubst_concl.
      repeat one_lift_lsubst2_concl.

      apply tequality_isect; dands.

      - apply tequality_set; dands.

        { apply tequality_int. }

        introv e3.
        repeat substc_lsubstc_vars3.
        repeat one_lift_lsubst_concl.
        apply tequality_mkc_member_sp; dands.

        + unfold mk_natk_aux.
          repeat one_lift_lsubst_concl.
          repeat one_lift_lsubst2_concl.
          apply tequality_set; dands.

          { apply tequality_int. }

          introv e4.

          repeat substc_lsubstc_vars3.
          repeat one_lift_lsubst_concl.
          apply tequality_mkc_prod; dands.

          { repeat one_lift_lsubst2_concl.
            repeat one_lift_lsubst_concl.
            repeat (rw @lsubstc_cons_var).

            clear_cv.

            apply tequality_mkc_le.
            apply equality_in_int in e4.
            unfold equality_of_int in e4; exrepnd.
            exists (0%Z) k (0%Z) k; dands; spcast; auto;
            try (complete (unfold computes_to_valc; simpl;
                           unfold computes_to_value; dands;
                           eauto with slow)).

            destruct (Z_le_gt_dec 0 k); tcsp.
            right; dands; omega. }

          revert e1 e4.

          repeat one_lift_lsubst2_concl.
          repeat one_lift_lsubst_concl.
          repeat (rw @lsubstc_cons_var).
          lsubstc_snoc.
          introv e1 e4 inh1.

          apply equality_in_int_and_inhabited_le_implies_equality_in_nat in e4; auto.
          apply equality_in_tnat in e1.
          apply equality_in_tnat in e4.
          unfold equality_of_nat in e1.
          unfold equality_of_nat in e4.
          exrepnd.

          apply tequality_mkc_less_than.
          exists (Z.of_nat k) (Z.of_nat k3) (Z.of_nat k) (Z.of_nat k3).
          dands; spcast; auto.

          destruct (Z_lt_ge_dec (Z.of_nat k) (Z.of_nat k3)); tcsp.
          right; dands; omega.

        + right.
          unfold absolute_value, mk_natk_aux.
          repeat one_lift_lsubst2_concl.
          repeat one_lift_lsubst_concl.
          repeat one_lift_lsubst2_concl.
          repeat (rw @lsubstc_cons_var).
          revert e3; intro e3.
          fold (absolute_value_c a1).
          fold (absolute_value_c a'1).
          spcast.
          apply cequivc_absolute_value; auto.

      - introv e3.
        clear_cv.
        repeat substc_lsubstc_vars3.
        repeat one_lift_lsubst_concl.
        repeat one_lift_lsubst2_concl.
        repeat (rw @lsubstc_cons_var).
        lsubstc_snoc.
        clear_cv.

        apply tequality_mkc_equality_sp; dands; tcsp.

        { revert k0.
          repeat one_lift_lsubst2_concl; intro k.
          apply equality_in_set in e3; repnd.
          dorn k.

          - left.
            apply equality_in_fun in k; repnd.
            apply k; auto.

          - right.
            apply equality_in_int_implies_cequiv in e4; spcast.
            apply implies_cequivc_apply; auto.
        }

        { revert e2; intro e2.
          unfold int2int in e2.
          repeat (one_lift_lsubst_hyp e2).
          repeat (one_lift_lsubst2_hyp e2).
          apply equality_in_set in e3; repnd.
          left.
          apply equality_in_fun in e2; repnd.
          apply e2; auto.
        }
    }

    { clear_cv.
      repeat one_lift_lsubst2_concl.
      intro inh.
      lsubstc_snoc_concl.
      revert h1 h0; intros h0 h1.
      unfold member in h0.
      repeat (one_lift_lsubst_hyp h0).
      eapply cequorsq_equality_trans2 in h1;[clear h0|exact h0].
      repeat (one_lift_lsubst2_hyp h1).
      apply tequality_mkc_equality_sp; dands.

      { apply tequality_int. }

      { left.
        apply equality_in_fun in h1; repnd.
        apply h1.
        repeat (one_lift_lsubst_concl).
        repeat (one_lift_lsubst2_concl).

        revert k1 k0; intros k0 k1.
        unfold member in k0.
        repeat (one_lift_lsubst_hyp k0).
        repeat (one_lift_lsubst2_hyp k0).
        repeat (one_lift_lsubst2_hyp k1).
        eapply cequorsq_equality_trans2 in k1;[clear k0|exact k0].
        auto.
      }

      { left.
        apply equality_in_fun in h1; repnd.
        apply h1; auto. }
    }

  - apply equality_in_mkc_squash; dands; spcast; auto;
    try computes_to_value_refl.

    allrw @member_eq.
    allrw <- @member_member_iff.
    allrw @tequality_mkc_member_sp; repnd.
    allrw @fold_equorsq.

    pose proof (continuity_axiom_v2
                  lib
                  (lsubstc F wt1 s1 ct6)
                  (lsubstc T wt s1 ct2)) as cont.
    repeat (autodimp cont hyp).
    (* I need to generalize agree_upto in Lemma comp_force_int_step3_2 in continuity3_2_v2,
       which is used in Lemma continuity_axiom_v2 in continuity_axiom2_v2.
       First, I should try to generalize the "modulo alpha" to "modulo squiggle".
     *)
    {
      revert h1; unfold member; intro h.
      repeat (one_lift_lsubst_hyp h).
      eapply alphaeqc_preserving_equality;[apply h|].
      apply alphaeqc_mkc_fun; eauto 2 with slow.

      pose proof (lsubstc_mk_fun_ex mk_int T s1 wT0 cT1) as xx; exrepnd.
      eapply alphaeqc_trans;[exact xx1|clear xx1].
      clear_irr.
      rw @lsubstc_mk_int.
      apply alphaeqc_refl.
    }

    pose proof (cont (lsubstc f wt0 s1 ct4)) as cont1; clear cont.
    autodimp cont1 hyp.
    {
      revert k1; unfold member; intro h.
      repeat (one_lift_lsubst_hyp h).
      repeat (one_lift_lsubst2_hyp h).
      auto.
    }

    exrepnd.
    unfold continuous_type_v2, continuous_type_aux_v2; simpl.
    repeat (one_lift_lsubst_concl).
    repeat (one_lift_lsubst2_concl).
    exists (@mkc_pair p (mkc_nat b) mkc_axiom).

    rw @tequality_mkc_squash in teq.
    apply tequality_refl in teq.
    rw @fold_type in teq.
    unfold continuous_type_v2, continuous_type_aux_v2 in teq; simpl in teq.
    repeat (one_lift_lsubst_hyp teq).
    repeat (one_lift_lsubst2_hyp teq).

    apply member_product2; dands; auto.

    apply tequality_product in teq; repnd.
    pose proof (teq (mkc_nat b) (mkc_nat b)) as teq2; clear teq.
    allrw @fold_type.

    keepdimp teq2 teq.
    {
      apply equality_in_tnat.
      exists b; dands; spcast; eauto with slow;
      apply computes_to_valc_refl; eauto with slow.
    }

    exists (@mkc_nat p b) (@mkc_axiom p); dands; spcast; auto.

    { apply computes_to_valc_refl; eauto with slow. }

    { repeat substc_lsubstc_vars3.
      repeat one_lift_lsubst_concl.
      repeat (one_lift_lsubst_hyp teq2).
      allrw (@lsubstc_int2int).
      clear_cv.

      apply tequality_isect in teq2; repnd.

      apply equality_in_isect; dands; auto.

      intros g1 g2 e1.
      pose proof (teq2 g1 g2 e1) as teq3; clear teq2.
      allrw @fold_type.
      repeat substc_lsubstc_vars3.
      repeat one_lift_lsubst_concl.
      repeat (one_lift_lsubst_hyp teq3).
      clear_cv.
      apply tequality_refl in teq3.
      rw @fold_type in teq3.

      apply tequality_mkc_ufun in teq3; repnd.
      apply equality_in_ufun; dands; auto.
      intro inh.
      autodimp teq3 hyp;[].
      apply tequality_refl in teq2.
      apply tequality_refl in teq3.
      allrw @fold_type.

      revert teq3.
      lsubstc_snoc_concl.
      intro teq3.
      apply tequality_mkc_equality_sp in teq3; repnd.

      revert e1; intro e1.
      repeat (one_lift_lsubst_hyp e1).
      revert e1; lsubstc_snoc_concl; intro e1.

      pose proof (cont0 g1) as cont1; clear cont0.
      autodimp cont1 hyp.
      { apply equality_refl in e1; auto. }

      keepdimp cont1 cont2.
      {
        introv r1 r2 l.
        unfold agree_upto_b_type_v2 in inh.
        repeat (one_lift_lsubst_hyp inh).
        unfold inhabited_type in inh; exrepnd.
        rw @equality_in_isect in inh0; repnd.
        pose proof (inh0 t2 t2) as inh; clear inh0.
        repeat (one_lift_lsubst2_hyp inh1).
        repeat (one_lift_lsubst2_hyp inh2).
        repeat (one_lift_lsubst2_hyp inh).
        autodimp inh hyp.
        {
          rw @tequality_set in inh1; repnd.
          assert (equality lib t2 t2 mkc_int) as ei.
          {
            apply equality_in_int.
            exists i0; dands; spcast; auto;
            apply computes_to_valc_iff_reduces_toc; eauto with slow.
          }

          rw @equality_in_set; dands; auto; [].
          applydup inh1 in ei as inh3; clear inh1 inh2.
          repeat substc_lsubstc_vars3.
          apply tequality_refl in inh3.
          allrw @fold_type.
          repeat one_lift_lsubst_concl.
          repeat (one_lift_lsubst_hyp inh3).
          exists (@mkc_axiom p).
          rw <- @member_member_iff.
          apply tequality_mkc_member_sp in inh3; repnd.
          allrw @fold_type.
          clear inh3.

          unfold absolute_value, mk_natk_aux.
          unfold absolute_value, mk_natk_aux in inh1.
          repeat one_lift_lsubst2_concl.
          repeat one_lift_lsubst_concl.
          repeat one_lift_lsubst2_concl.
          repeat (rw @lsubstc_cons_var).
          fold (absolute_value_c t2).

          repeat (one_lift_lsubst_hyp inh1).
          repeat (one_lift_lsubst2_hyp inh1).
          rw @tequality_set in inh1; repnd.

          pose proof (inh1 (absolute_value_c t2) (absolute_value_c t2)) as inh.
          keepdimp inh ai.
          {
            apply equality_in_int.
            unfold equality_of_int.
            exists (Z.abs i0).
            dands; spcast; apply computes_to_valc_absolute_value; auto;
            apply computes_to_valc_iff_reduces_toc; eauto with slow.
          }

          apply equality_in_set; dands; auto; clear inh1;[].

          repeat substc_lsubstc_vars3.
          apply tequality_refl in inh.
          allrw @fold_type.
          repeat (one_lift_lsubst_hyp inh).
          repeat (one_lift_lsubst2_hyp inh).
          repeat (one_lift_lsubst_concl).
          repeat (one_lift_lsubst2_concl).
          clear_cv.

          apply type_mkc_prod in inh; repnd.
          apply inhabited_prod2.

          prove_and ty1; GC.

          prove_and it1;[|prove_and ty2]; auto; GC.

          {
            repeat (one_lift_lsubst_hyp inh1).
            repeat (one_lift_lsubst2_hyp inh1).
            repeat (one_lift_lsubst_concl).
            repeat (one_lift_lsubst2_concl).
            lsubstc_snoc_concl.
            lsubstc_snoc_hyp inh1.
            apply inhabited_le.
            exists (0%Z) (Z.abs i0).
            dands; spcast;
            try (complete (unfold computes_to_valc; simpl;
                           unfold computes_to_value; dands;
                           eauto with slow));
            try (complete (apply computes_to_valc_absolute_value; auto;
                           apply computes_to_valc_iff_reduces_toc; eauto with slow)).
            destruct i0; allsimpl; try omega; apply Pos2Z.is_nonneg.
          }

          {
            autodimp inh hyp.
            repeat (one_lift_lsubst_hyp inh).
            repeat (one_lift_lsubst2_hyp inh).
            repeat (one_lift_lsubst_concl).
            repeat (one_lift_lsubst2_concl).
            lsubstc_snoc_concl.
            lsubstc_snoc_hyp inh.
            apply inhabited_less_than.
            exists (Z.abs i0) (Z.of_nat b).
            dands; spcast;
            try (complete (unfold computes_to_valc; simpl;
                           unfold computes_to_value; dands;
                           eauto with slow));
            try (complete (apply computes_to_valc_absolute_value; auto;
                           apply computes_to_valc_iff_reduces_toc; eauto with slow)).
            revert l; intro l.
            destruct i0; allsimpl; try omega; rw <- Znat.positive_nat_Z; apply Znat.inj_lt; auto.
          }
        }

        repeat substc_lsubstc_vars3.
        repeat (one_lift_lsubst_hyp inh).
        repeat (one_lift_lsubst2_hyp inh).
        revert inh.
        lsubstc_snoc_concl.
        intro inh.
        revert k1; intro k1.
        repeat (one_lift_lsubst_hyp k1).

        rw @equality_in_fun in k1; repnd.
        pose proof (k1 t1 t2) as ef; autodimp ef hyp.
        {
          apply equality_in_int.
          exists i0; dands; spcast; auto;
          apply computes_to_valc_iff_reduces_toc; eauto with slow.
        }

        apply equality_in_mkc_equality in inh; repnd.
        eapply equality_trans;[exact ef|]; auto.
      }

      rw @member_eq.
      rw <- @member_equality_iff.
      repeat (one_lift_lsubst2_concl).
      apply equality_in_int.
      unfold equality_of_int_tt in cont1; exrepnd.
      exists k; dands; spcast; auto.
    }
Qed.
