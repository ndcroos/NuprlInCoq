(*

  Copyright 2014 Cornell University
  Copyright 2015 Cornell University
  Copyright 2016 Cornell University
  Copyright 2017 Cornell University
  Copyright 2018 Cornell University

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


Require Export sequents2.
Require Export sequents_tacs.
Require Export sequents_tacs2.
Require Export Classical_Prop.
Require Export per_props_union.
Require Export per_props_equality.
Require Export per_props_squash.
Require Export per_props_not.
Require Export sequents_squash.
Require Export lsubstc_vars.
Require Export rules_choice.


Lemma mkcv_union_substc {o} :
  forall v a b (t : @CTerm o),
    substc t v (mkcv_union [v] a b)
    = mkc_union (substc t v a) (substc t v b).
Proof.
  introv.
  destruct_cterms.
  apply cterm_eq; simpl.
  repeat unfsubst.
Qed.
Hint Rewrite @mkcv_union_substc : slow.

Lemma mkcv_or_substc {o} :
  forall v a b (t : @CTerm o),
    substc t v (mkcv_or [v] a b)
    = mkc_or (substc t v a) (substc t v b).
Proof.
  introv.
  destruct_cterms.
  apply cterm_eq; simpl.
  repeat unfsubst.
Qed.
Hint Rewrite @mkcv_or_substc : slow.

Lemma mk_cv_app_r_mkc_var {o} :
  forall (a : @CTerm o) v t,
    substc a v (mk_cv_app_r [] [v] t) = substc a v t.
Proof.
  introv.
  destruct_cterms.
  apply cterm_eq; simpl; auto.
Qed.
Hint Rewrite @mk_cv_app_r_mkc_var : slow.

Lemma lsubstc_vars_void {o} :
  forall (w : @wf_term o mk_void) s vs c,
    lsubstc_vars mk_void w s vs c
    = mkcv_void vs.
Proof.
  introv; apply cvterm_eq; simpl; auto.
  unfold mk_void, mk_false; simpl.
  unfold csubst.
  rewrite cl_lsubst_trivial; simpl; auto; eauto 3 with slow.
Qed.
Hint Rewrite @lsubstc_vars_void : slow.

Lemma lsubstc_vars_mk_not_as_mkcv {o} :
  forall (t : @NTerm o) (w : wf_term (mk_not t))
         (s : CSub) (vs : list NVar)
         (c : cover_vars_upto (mk_not t) s vs),
  {w1 : wf_term t $
  {c1 : cover_vars_upto t s vs $
  alphaeqcv
    vs
    (lsubstc_vars (mk_not t) w s vs c)
    (mkcv_not vs (lsubstc_vars t w1 s vs c1))}}.
Proof.
  introv.
  pose proof (lsubstc_vars_mk_fun_as_mkcv t mk_void w s vs c) as q; exrepnd.
  exists w1 c1; auto.
  unfold mk_not; rewrite mkcv_not_eq; auto.
  autorewrite with slow in *; auto.
Qed.

Hint Rewrite @mkcv_not_substc : slow.

Lemma isprog_vars_choice_seq_implies {o} :
  forall vs name, @isprog_vars o vs (mk_choice_seq name).
Proof.
  introv.
  allrw @isprog_vars_eq.
  simpl in *; autorewrite with slow.
  repnd; dands; auto; eauto 3 with slow.
Qed.
Hint Resolve isprog_vars_choice_seq_implies : slow.

Definition mkcv_choice_seq {o} vs (n : choice_sequence_name) : @CVTerm o vs :=
  exist (isprog_vars vs) (mk_choice_seq n) (isprog_vars_choice_seq_implies vs n).

Definition exists_1_choice {o} (a : choice_sequence_name) (n : NVar) : @CTerm o :=
  mkc_exists
    mkc_tnat
    n
    (mkcv_equality
       _
       (mkcv_apply _ (mkcv_choice_seq _ a) (mkc_var n))
       (mkcv_one _)
       (mkcv_tnat _)).

Lemma int_in_uni {o} : forall i lib, @equality o lib mkc_int mkc_int (mkc_uni i).
Proof.
  introv.
  exists (per_bar_eq (trivial_bar lib) (univi_eq_lib_per lib i)).
  dands; auto; eauto 3 with slow;[].

  introv br ext; introv.
  exists (trivial_bar lib'0).
  apply in_ext_ext_implies_all_in_bar_ext_trivial_bar.
  introv; simpl.
  unfold univi_eq.

  exists (equality_of_int_bar lib'1).
  apply CL_int.
  unfold per_int; dands; spcast; eauto 3 with slow.
Qed.
Hint Resolve int_in_uni : slow.

Lemma mkc_less_aux_in_uni {o} :
  forall i lib (a b c d e f g h : @CTerm o) ka kb ke kf,
    computes_to_valc lib a (mkc_integer ka)
    -> computes_to_valc lib b (mkc_integer kb)
    -> computes_to_valc lib e (mkc_integer ke)
    -> computes_to_valc lib f (mkc_integer kf)
    -> (equality lib (mkc_less a b c d) (mkc_less e f g h) (mkc_uni i)
        <=>
        (
          ((ka < kb)%Z # (ke < kf)%Z # equality lib c g (mkc_uni i))
          [+]
          ((kb <= ka)%Z # (kf <= ke)%Z # equality lib d h (mkc_uni i))
          [+]
          ((ka < kb)%Z # (kf <= ke)%Z # equality lib c h (mkc_uni i))
          [+]
          ((kb <= ka)%Z # (ke < kf)%Z # equality lib d g (mkc_uni i))
        )
       ).
Proof.
  introv ca cb ce cf.

  assert (ccequivc_ext
            lib
            (mkc_less a b c d)
            (mkc_less (mkc_integer ka) (mkc_integer kb) c d)) as c1.
  { apply reduces_toc_implies_ccequivc_ext.
    destruct_cterms; allunfold @reduces_toc; allunfold @computes_to_valc; allsimpl.
    apply reduce_to_prinargs_comp; eauto with slow. }

  assert (ccequivc_ext
            lib
            (mkc_less e f g h)
            (mkc_less (mkc_integer ke) (mkc_integer kf) g h)) as c2.
  { apply reduces_toc_implies_ccequivc_ext.
    destruct_cterms; allunfold @reduces_toc; allunfold @computes_to_valc; allsimpl.
    apply reduce_to_prinargs_comp; eauto with slow. }

  split; intro k; repnd.

  - destruct (Z_lt_ge_dec ka kb); destruct (Z_lt_ge_dec ke kf).

    + left; dands; auto.

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ka) (mkc_integer kb) c d)
                c) as c3.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ke) (mkc_integer kf) g h)
                g) as c4.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      eapply equality_respects_cequivc_left;[exact c3|].
      eapply equality_respects_cequivc_right;[exact c4|].
      eapply equality_respects_cequivc_left;[exact c1|].
      eapply equality_respects_cequivc_right;[exact c2|].
      auto.

    + right; right; left; dands; auto; try omega.

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ka) (mkc_integer kb) c d)
                c) as c3.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ke) (mkc_integer kf) g h)
                h) as c4.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      eapply equality_respects_cequivc_left;[exact c3|].
      eapply equality_respects_cequivc_right;[exact c4|].
      eapply equality_respects_cequivc_left;[exact c1|].
      eapply equality_respects_cequivc_right;[exact c2|].
      auto.

    + right; right; right; dands; auto; try omega.

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ka) (mkc_integer kb) c d)
                d) as c3.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ke) (mkc_integer kf) g h)
                g) as c4.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      eapply equality_respects_cequivc_left;[exact c3|].
      eapply equality_respects_cequivc_right;[exact c4|].
      eapply equality_respects_cequivc_left;[exact c1|].
      eapply equality_respects_cequivc_right;[exact c2|].
      auto.

    + right; left; dands; auto; try omega.

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ka) (mkc_integer kb) c d)
                d) as c3.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ke) (mkc_integer kf) g h)
                h) as c4.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      eapply equality_respects_cequivc_left;[exact c3|].
      eapply equality_respects_cequivc_right;[exact c4|].
      eapply equality_respects_cequivc_left;[exact c1|].
      eapply equality_respects_cequivc_right;[exact c2|].
      auto.

  - eapply equality_respects_cequivc_left;[apply ccequivc_ext_sym; exact c1|].
    eapply equality_respects_cequivc_right;[apply ccequivc_ext_sym; exact c2|].
    clear c1 c2 ca cb ce cf.
    repndors; exrepnd.

    + assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ka) (mkc_integer kb) c d)
                c) as c3.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ke) (mkc_integer kf) g h)
                g) as c4.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      eapply equality_respects_cequivc_left;[apply ccequivc_ext_sym; exact c3|].
      eapply equality_respects_cequivc_right;[apply ccequivc_ext_sym; exact c4|].
      auto.

    + assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ka) (mkc_integer kb) c d)
                d) as c3.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ke) (mkc_integer kf) g h)
                h) as c4.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      eapply equality_respects_cequivc_left;[apply ccequivc_ext_sym; exact c3|].
      eapply equality_respects_cequivc_right;[apply ccequivc_ext_sym; exact c4|].
      auto.

    + assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ka) (mkc_integer kb) c d)
                c) as c3.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ke) (mkc_integer kf) g h)
                h) as c4.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      eapply equality_respects_cequivc_left;[apply ccequivc_ext_sym; exact c3|].
      eapply equality_respects_cequivc_right;[apply ccequivc_ext_sym; exact c4|].
      auto.

    + assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ka) (mkc_integer kb) c d)
                d) as c3.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      assert (ccequivc_ext
                lib
                (mkc_less (mkc_integer ke) (mkc_integer kf) g h)
                g) as c4.
      { apply reduces_toc_implies_ccequivc_ext.
        destruct_cterms; unfold reduces_toc; simpl.
        apply reduces_to_if_step; csunf; simpl.
        dcwf h; simpl.
        unfold compute_step_comp; simpl; boolvar; tcsp; try omega. }

      eapply equality_respects_cequivc_left;[apply ccequivc_ext_sym; exact c3|].
      eapply equality_respects_cequivc_right;[apply ccequivc_ext_sym; exact c4|].
      auto.
Qed.

Lemma mkc_less_in_uni {o} :
  forall i lib (a b c d e f g h : @CTerm o),
    equality lib (mkc_less a b c d) (mkc_less e f g h) (mkc_uni i)
    <=>
    all_in_ex_bar
      lib
      (fun lib =>
         {ka , kb , ke , kf : Z
         , a ===>(lib) (mkc_integer ka)
         # b ===>(lib) (mkc_integer kb)
         # e ===>(lib) (mkc_integer ke)
         # f ===>(lib) (mkc_integer kf)
         # (
             ((ka < kb)%Z # (ke < kf)%Z # equality lib c g (mkc_uni i))
             {+}
             ((kb <= ka)%Z # (kf <= ke)%Z # equality lib d h (mkc_uni i))
             {+}
             ((ka < kb)%Z # (kf <= ke)%Z # equality lib c h (mkc_uni i))
             {+}
             ((kb <= ka)%Z # (ke < kf)%Z # equality lib d g (mkc_uni i))
           )}).
Proof.
  introv.

  split; intro q; exrepnd.

  - applydup @equality_in_uni in q as k.
    applydup @tequality_refl in k.
    applydup @tequality_sym in k.
    apply tequality_refl in k1.
    allrw @fold_type.
    apply types_converge in k0.
    apply types_converge in k1.

    eapply all_in_ex_bar_modus_ponens2;[|exact k0|exact k1].
    clear k0 k1; introv x k0 k1.
    spcast.

    apply hasvaluec_mkc_less in k0.
    apply hasvaluec_mkc_less in k1.
    exrepnd.

    exists k6 k0 k2 k1; dands; spcast; eauto with slow;
    try (complete (apply computes_to_valc_iff_reduces_toc; dands; eauto 3 with slow)).

    pose proof (mkc_less_aux_in_uni
                  i lib' a b c d e f g h k6 k0 k2 k1) as p.
    repeat (autodimp p hyp);
      try (complete (apply computes_to_valc_iff_reduces_toc; dands; eauto 3 with slow)).

    eapply equality_monotone in q;[|exact x].
    apply p in q; sp.

  - apply all_in_ex_bar_equality_implies_equality.
    eapply all_in_ex_bar_modus_ponens1;[|exact q]; clear q; introv x k.
    exrepnd.
    pose proof (mkc_less_aux_in_uni
                  i lib' a b c d e f g h ka kb ke kf) as p.
    spcast.
    repeat (autodimp p hyp).
    apply p.

    destruct (Z_lt_ge_dec ka kb); destruct (Z_lt_ge_dec ke kf).

    + left; dands; auto.
      repndors; repnd; try omega; auto.

    + right; right; left; dands; auto; try omega.
      repndors; repnd; try omega; auto.

    + right; right; right; dands; auto; try omega.
      repndors; repnd; try omega; auto.

    + right; left; dands; auto; try omega.
      repndors; repnd; try omega; auto.
Qed.

Lemma false_in_uni {p} :
  forall i lib, @equality p lib mkc_false mkc_false (mkc_uni i).
Proof.
  introv.
  rw @mkc_false_eq.
  apply mkc_approx_equality_in_uni.
  exists (trivial_bar lib).
  apply in_ext_implies_all_in_bar_trivial_bar; introv e.
  split; intro k; spcast; apply not_axiom_approxc_bot in k; sp.
Qed.
Hint Resolve false_in_uni : slow.

Lemma void_in_uni {p} :
  forall i lib, @equality p lib mkc_void mkc_void (mkc_uni i).
Proof.
  introv; rw @mkc_void_eq_mkc_false; eauto 3 with slow.
Qed.
Hint Resolve void_in_uni : slow.

Lemma true_in_uni {p} :
  forall i lib, @equality p lib mkc_true mkc_true (mkc_uni i).
Proof.
  introv.
  rw @mkc_true_eq.
  apply mkc_approx_equality_in_uni.
  exists (trivial_bar lib).
  apply in_ext_implies_all_in_bar_trivial_bar; introv e.
  split; intro k; spcast; tcsp.
Qed.
Hint Resolve true_in_uni : slow.

Lemma mkc_less_than_in_uni {o} :
  forall i lib (a b c d : @CTerm o),
    equality lib (mkc_less_than a b) (mkc_less_than c d) (mkc_uni i)
    <=>
    all_in_ex_bar
      lib
      (fun lib =>
         {ka , kb , kc , kd : Z
         , a ===>(lib) (mkc_integer ka)
         # b ===>(lib) (mkc_integer kb)
         # c ===>(lib) (mkc_integer kc)
         # d ===>(lib) (mkc_integer kd)
         # (
             ((ka < kb)%Z # (kc < kd)%Z)
             {+}
             ((kb <= ka)%Z # (kd <= kc)%Z)
           )}).
Proof.
  introv.
  allrw @mkc_less_than_eq.
  rw (mkc_less_in_uni i lib a b mkc_true mkc_false c d mkc_true mkc_false).

  split; intro k; exrepnd.

  - eapply all_in_ex_bar_modus_ponens1;[|exact k]; clear k; introv x k; exrepnd.
    exists ka kb ke kf; dands; auto.
    repndors; repnd; tcsp.

    + apply equality_in_uni in k1.
      apply true_not_equal_to_false in k1; sp.

    + apply equality_in_uni in k1.
      apply tequality_sym in k1.
      apply true_not_equal_to_false in k1; sp.

  - eapply all_in_ex_bar_modus_ponens1;[|exact k]; clear k; introv x k; exrepnd.
    exists ka kb kc kd; dands; auto.
    repndors; repnd; tcsp.

    { left; dands; eauto 3 with slow. }

    { right; left; dands; eauto 3 with slow. }
Qed.

Lemma fun_in_uni {p} :
  forall i lib (A1 A2 B1 B2 : @CTerm p),
    equality lib (mkc_fun A1 B1) (mkc_fun A2 B2) (mkc_uni i)
    <=>
    (equality lib A1 A2 (mkc_uni i)
      # (forall lib' (x : lib_extends lib' lib), inhabited_type lib' A1 -> equality lib' B1 B2 (mkc_uni i))).
Proof.
  intros.
  allrw <- @fold_mkc_fun.
  rw (equality_function lib).
  split; intro teq; repnd; dands; auto; introv x e.

  - unfold inhabited_type in e; exrepnd.
    generalize (teq lib' x t t); intro k; autodimp k hyp.
    repeat (rw @csubst_mk_cv in k); sp.

  - pose proof (teq lib' x) as teq.
    autodimp teq hyp.
    exists a; allapply @equality_refl; sp.
    repeat (rw @csubst_mk_cv); sp.
Qed.

Lemma not_in_uni {p} :
  forall i lib (A1 A2 : @CTerm p),
    equality lib (mkc_not A1) (mkc_not A2) (mkc_uni i)
    <=>
    equality lib A1 A2 (mkc_uni i).
Proof.
  intros.
  rw @fun_in_uni; split; sp; eauto 3 with slow.
Qed.

Lemma mkc_le_in_uni {o} :
  forall i lib (a b c d : @CTerm o),
    equality lib (mkc_le a b) (mkc_le c d) (mkc_uni i)
    <=>
    all_in_ex_bar
      lib
      (fun lib =>
         {ka , kb , kc , kd : Z
         , a ===>(lib) (mkc_integer ka)
         # b ===>(lib) (mkc_integer kb)
         # c ===>(lib) (mkc_integer kc)
         # d ===>(lib) (mkc_integer kd)
         # (
             ((ka <= kb)%Z # (kc <= kd)%Z)
             {+}
             ((kb < ka)%Z # (kd < kc)%Z)
           )}).
Proof.
  introv.
  allrw @mkc_le_eq.
  rw @not_in_uni.
  rw @mkc_less_than_in_uni.

  split; intro k.

  - eapply all_in_ex_bar_modus_ponens1;[|exact k]; clear k; introv x k; exrepnd; spcast.
    exists kb ka kd kc; dands; spcast; auto.
    repndors; repnd; tcsp.

  - eapply all_in_ex_bar_modus_ponens1;[|exact k]; clear k; introv x k; exrepnd; spcast.
    exists kb ka kd kc; dands; spcast; auto.
    repndors; repnd; tcsp.
Qed.

Lemma tnat_in_uni {o} : forall i lib, @equality o lib mkc_tnat mkc_tnat (mkc_uni i).
Proof.
  introv.
  rw @mkc_tnat_eq.
  apply equality_set; dands; eauto 3 with slow.
  introv ext ea.
  autorewrite with slow.
  apply equality_in_int in ea.
  apply all_in_ex_bar_equality_implies_equality.
  eapply all_in_ex_bar_modus_ponens1;[|exact ea]; clear ea; introv y ea; exrepnd; spcast.
  unfold equality_of_int in ea; exrepnd; spcast.

  clear lib lib' ext y.
  rename lib'0 into lib.

  apply mkc_le_in_uni.
  exists (trivial_bar lib).
  apply in_ext_implies_all_in_bar_trivial_bar.
  introv ext; simpl.
  exists 0%Z k 0%Z k.
  rw @mkc_zero_eq; rw @mkc_nat_eq; simpl.
  dands; spcast; auto; eauto 3 with slow.
  destruct (Z_lt_le_dec k 0); tcsp.
Qed.
Hint Resolve tnat_in_uni : slow.

Hint Rewrite @mkcv_apply_substc : slow.

Lemma substc_mkcv_choice_seq {o} :
  forall v name (t : @CTerm o),
    (mkcv_choice_seq [v] name) [[v \\ t]] = mkc_choice_seq name.
Proof.
  introv; destruct_cterms; apply cterm_eq; simpl; unfsubst.
Qed.
Hint Rewrite @substc_mkcv_choice_seq : slow.

Definition choice_sequence_name_and_seq2choice_seq_entry {o} (name : choice_sequence_name) (l : list nat) : @ChoiceSeqEntry o :=
  MkChoiceSeqEntry
    _
    (map mkc_nat l)
    (choice_sequence_name2restriction name).

Definition choice_sequence_name_and_seq2entry {o} (name : choice_sequence_name) (l : list nat) : @library_entry o :=
  lib_cs name (choice_sequence_name_and_seq2choice_seq_entry name l).

Lemma entry_extends_choice_sequence_name2entry {o} :
  forall (entry : @library_entry o) name,
    safe_library_entry entry
    -> csn_kind name = cs_kind_seq []
    -> entry_extends entry (choice_sequence_name2entry name)
    -> exists l restr,
        entry = lib_cs name (MkChoiceSeqEntry _ (map mkc_nat l) restr)
        /\ same_restrictions restr (csc_seq []).
Proof.
  introv safe ck ext.
  unfold entry_extends in ext.
  destruct entry; simpl in *; repnd; ginv; subst.
  destruct entry as [vals restr]; simpl in *.
  unfold choice_sequence_entry_extend in *; simpl in *; repnd.
  unfold same_restrictions in ext0.
  unfold choice_sequence_name2restriction in *.
  destruct name; simpl in *; subst.
  destruct restr; simpl in *; tcsp; ginv; repnd.
  unfold choice_sequence_vals_extend in ext; exrepnd; simpl in *; subst.
  unfold choice_sequence_name_and_seq2entry; simpl.
  unfold choice_sequence_name_and_seq2choice_seq_entry; simpl.
  unfold choice_sequence_name2restriction; simpl.
  unfold correct_restriction in *; simpl in *; repnd.

  assert (forall v, LIn v vals0 -> exists (i : nat), v = mkc_nat i) as vn.
  {
    introv q.
    apply in_nth in q; exrepnd.
    pose proof (safe n v) as q.
    autodimp q hyp.
    { erewrite nth_select1; auto; rewrite q0 at 1; eauto. }
    apply safe0 in q; auto; try omega.
  }
  clear safe.

  assert (exists l, vals0 = map mkc_nat l) as h.
  {
    induction vals0; simpl in *; tcsp.
    - exists ([] : list nat); simpl; auto.
    - autodimp IHvals0 hyp; tcsp.
      exrepnd; subst.
      pose proof (vn a) as vn; autodimp vn hyp; exrepnd; subst.
      exists (i :: l); simpl; auto.
  }

  exrepnd; subst.
  exists l (csc_type d typ typd); dands; auto.
  unfold same_restrictions; simpl; dands; auto.
Qed.

Lemma map_mkc_nat_ntimes {o} :
  forall n k,
    map mkc_nat (ntimes n k)
    = ntimes n (@mkc_nat o k).
Proof.
  induction n; introv; simpl; auto.
  allrw; simpl; auto.
Qed.

Lemma entry_in_inf_library_extends_const {o} :
  forall n (entry : @library_entry o) d,
    entry_in_inf_library_extends entry n (fun _ => d) -> inf_entry_extends d entry.
Proof.
  induction n; introv i; simpl in *; tcsp.
Qed.
Hint Resolve entry_in_inf_library_extends_const : slow.

Lemma matching_entries_preserves_inf_matching_entries_library_entry2inf {o} :
  forall (e1 e2 : @library_entry o) e,
    matching_entries e1 e2
    -> inf_entry_extends (library_entry2inf e2) e
    -> inf_matching_entries (library_entry2inf e1) e.
Proof.
  introv m i.
  unfold inf_entry_extends in i.
  unfold matching_entries in m.
  destruct e1, e2, e; simpl in *; repnd; subst; tcsp.
Qed.
Hint Resolve matching_entries_preserves_inf_matching_entries_library_entry2inf : slow.

Lemma entry_in_inf_library_extends_library2inf_implies {o} :
  forall n entry d (lib : @library o),
    entry_in_inf_library_extends entry n (library2inf lib d)
    -> inf_entry_extends d entry
       \/ exists e, entry_in_library e lib /\ inf_entry_extends (library_entry2inf e) entry.
Proof.
  induction n; introv i; simpl in *; tcsp.
  repndors; repnd; subst; tcsp.

  { unfold library2inf in *; simpl in *.
    destruct lib; simpl; tcsp.
    right; exists l; tcsp. }

  destruct lib; simpl in *; autorewrite with slow in *.

  { unfold shift_inf_lib, library2inf in i; simpl in i.
    apply entry_in_inf_library_extends_const in i; tcsp. }

  unfold library2inf in i0; simpl in i0.
  apply IHn in i; clear IHn.

  repndors; exrepnd; subst; tcsp.
  right; exists e; dands; tcsp.
  right; dands; auto.
  introv m; apply matching_entries_sym in m; destruct i0; eauto 2 with slow.
Qed.

Lemma inf_entry_extends_lib_cs_implies_matching {o} :
  forall (e : @inf_library_entry o) name x,
    inf_entry_extends e (lib_cs name x) -> entry_name_cs name = inf_entry2name e.
Proof.
  introv h.
  destruct e; simpl in *; repnd; subst; tcsp.
Qed.

Lemma inf_entry2name_library_entry2inf {o} :
  forall (e : @library_entry o),
    inf_entry2name (library_entry2inf e)
    = entry2name e.
Proof.
  introv; destruct e; simpl; auto.
Qed.
Hint Rewrite @inf_entry2name_library_entry2inf : slow.

Lemma two_entries_in_library_with_same_name {o} :
  forall (e1 e2 : @library_entry o) name lib,
    entry2name e1 = entry_name_cs name
    -> entry2name e2 = entry_name_cs name
    -> entry_in_library e1 lib
    -> entry_in_library e2 lib
    -> e1 = e2.
Proof.
  induction lib; introv eqname1 eqname2 h q; simpl in *; tcsp.
  repndors; repnd; subst; tcsp.

  - destruct h0.
    unfold matching_entries.
    rewrite eqname1, eqname2; simpl; auto.

  - destruct q0.
    unfold matching_entries.
    rewrite eqname1, eqname2; simpl; auto.
Qed.

Lemma implies_list_eq_ntimes :
  forall {A} l (x : A),
    (forall v, LIn v l -> v = x)
    -> l = ntimes (length l) x.
Proof.
  induction l; introv h; simpl in *; tcsp.
  erewrite IHl; eauto.
  pose proof (h a) as q; autodimp q hyp; subst.
  autorewrite with slow; auto.
Qed.
Hint Resolve implies_list_eq_ntimes : slow.

Lemma entry_extends_choice_sequence_name2entry_implies {o} :
  forall (lib : @library o) name name0 lib' entry',
    name <> name0
    -> safe_library_entry entry'
    -> csn_kind name = cs_kind_seq []
    -> inf_lib_extends (library2inf lib (simple_inf_choice_seq name0)) lib'
    -> entry_in_library (choice_sequence_name2entry name) lib
    -> entry_in_library entry' lib'
    -> entry_extends entry' (choice_sequence_name2entry name)
    -> exists restr n,
        entry' = lib_cs name (MkChoiceSeqEntry _ (ntimes n mkc_zero) restr)
        /\ same_restrictions restr (csc_seq []).
Proof.
  introv dname safe ck iext ilib ilib' ext.
  apply entry_extends_choice_sequence_name2entry in ext; auto; exrepnd; subst.
  simpl in *; repnd.
  exists restr.

  assert (exists n, l = ntimes n 0) as h;
    [|exrepnd; subst; exists n; dands; auto;
      rewrite map_mkc_nat_ntimes; rewrite mkc_zero_eq; auto];[].

  applydup iext in ilib'.
  repndors; simpl in *.

  - exrepnd.
    apply entry_in_inf_library_extends_library2inf_implies in ilib'1; simpl in *.
    repndors; exrepnd; subst; tcsp;[].
    applydup @inf_entry_extends_lib_cs_implies_matching in ilib'0; simpl in *.
    autorewrite with slow in *.

    dup ilib'1 as m.
    eapply two_entries_in_library_with_same_name in m; try exact ilib; simpl; eauto.
    subst e; simpl in *; repnd; GC.
    unfold inf_choice_sequence_entry_extend in *; simpl in *; repnd.
    unfold inf_choice_sequence_vals_extend in *; simpl in *.
    unfold choice_seq_vals2inf in *; simpl in *.
    unfold restriction2default in *.
    unfold choice_sequence_name2restriction in ilib'0.
    rewrite ck in *; simpl in *.
    unfold natSeq2default in *; simpl in *.

    assert (forall v, LIn v l -> v = 0) as h.
    {
      introv q.
      apply in_nth in q; exrepnd.
      pose proof (ilib'0 n0 (mkc_nat v)) as q.
      rewrite select_map in q.
      autodimp q hyp.
      { erewrite nth_select1; auto; unfold option_map; rewrite q0 at 1; eauto. }
      autorewrite with slow in q.
      rewrite mkc_zero_eq in q.
      apply mkc_nat_eq_implies in q; auto.
    }

    clear ilib'0 ilib'.
    exists (length l); eauto 3 with slow.

  - unfold entry_in_inf_library_default in ilib'0; simpl in *; repnd; GC.
    unfold correct_restriction in *.
    rewrite ck in *; simpl in *.

    unfold is_default_choice_sequence in *.
    destruct restr; simpl in *; repnd; tcsp.
    exists (length l).
    apply implies_list_eq_ntimes.
    introv i.
    apply in_nth in i; exrepnd.
    pose proof (ilib'0 n (mkc_nat v)) as q.
    rewrite select_map in q.
    autodimp q hyp.
    { erewrite nth_select1; auto; unfold option_map; rewrite i0 at 1; eauto. }
    rewrite safe2 in q; try omega.
    rewrite mkc_zero_eq in q.
    apply mkc_nat_eq_implies in q; auto.
Qed.

Lemma select_ntimes :
  forall {A} n m (a : A),
    select n (ntimes m a)
    = if lt_dec n m then Some a else None.
Proof.
  induction n; introv; simpl.

  - destruct m; simpl; auto.

  - destruct m; simpl; auto.
    rewrite IHn.
    boolvar; try omega; tcsp.
Qed.

Hint Rewrite minus_plus : slow nat.

Lemma entry_extends_cs_zeros {o} :
  forall (entry : @library_entry o) name n restr,
    safe_library_entry entry
    -> csn_kind name = cs_kind_seq []
    -> entry_extends entry (lib_cs name (MkChoiceSeqEntry _ (ntimes n mkc_zero) restr))
    -> exists l restr,
        entry = lib_cs name (MkChoiceSeqEntry _ (map mkc_nat l) restr)
        /\ same_restrictions restr (csc_seq []).
Proof.
  introv safe ck ext.
  unfold entry_extends in ext.
  destruct entry; simpl in *; repnd; ginv; subst.
  destruct entry as [vals restr1]; simpl in *.
  unfold choice_sequence_entry_extend in *; simpl in *; repnd.
  unfold same_restrictions in ext0.
  destruct name; simpl in *; subst.
  unfold correct_restriction in *; simpl in *.
  unfold is_nat_seq_restriction in *.
  destruct restr1; simpl in *; tcsp; ginv; repnd.
  destruct restr; simpl in *; tcsp; ginv; repnd.
  unfold choice_sequence_vals_extend in ext; exrepnd; simpl in *; subst.

  assert (forall v, LIn v vals0 -> exists (i : nat), v = mkc_nat i) as vn.
  {
    introv q.
    apply in_nth in q; exrepnd.
    pose proof (safe (n + n0) v) as q.
    rewrite select_app_r in q; autorewrite with slow nat in *; try omega.
    autodimp q hyp.
    { erewrite nth_select1; auto; rewrite q0 at 1; eauto. }
    apply safe0 in q; auto; try omega.
  }
  clear safe.

  assert (exists l, vals0 = map mkc_nat l) as h.
  {
    induction vals0; simpl in *; tcsp.
    - exists ([] : list nat); simpl; auto.
    - autodimp IHvals0 hyp; tcsp.
      exrepnd; subst.
      pose proof (vn a) as vn; autodimp vn hyp; exrepnd; subst.
      exists (i :: l); simpl; auto.
  }

  exrepnd; subst.
  exists (ntimes n 0 ++ l) (csc_type d typ typd); dands; auto.

  {
    rewrite map_app.
    rewrite map_mkc_nat_ntimes.
    rewrite mkc_zero_eq; auto.
  }

  unfold same_restrictions; simpl; dands; auto.
  { introv; rewrite safe2; try omega.
    unfold natSeq2default; autorewrite with slow; auto. }
  { introv; rewrite safe0; try omega.
    unfold natSeq2restrictionPred; autorewrite with slow; tcsp. }
Qed.

Lemma entry_extends_cs_zeros_implies {o} :
  forall (lib : @library o) name name0 n restr lib' entry',
    name <> name0
    -> safe_library_entry entry'
    -> csn_kind name = cs_kind_seq []
    -> inf_lib_extends (library2inf lib (simple_inf_choice_seq name0)) lib'
    -> entry_in_library (lib_cs name (MkChoiceSeqEntry _ (ntimes n mkc_zero) restr)) lib
    -> same_restrictions restr (csc_seq [])
    -> entry_in_library entry' lib'
    -> entry_extends entry' (lib_cs name (MkChoiceSeqEntry _ (ntimes n mkc_zero) restr))
    -> exists restr n,
        entry' = lib_cs name (MkChoiceSeqEntry _ (ntimes n mkc_zero) restr)
        /\ same_restrictions restr (csc_seq []).
Proof.
  introv dname safe ck iext ilib srestr ilib' ext.
  apply entry_extends_cs_zeros in ext; exrepnd; subst; auto;[].
  simpl in *; repnd.
  exists restr0.

  assert (exists n, l = ntimes n 0) as h;
    [|exrepnd; subst; exists n0; dands; auto;
      rewrite map_mkc_nat_ntimes; rewrite mkc_zero_eq; auto].

  applydup iext in ilib'.
  repndors; simpl in *.

  - exrepnd.
    apply entry_in_inf_library_extends_library2inf_implies in ilib'1; simpl in *.
    repndors; exrepnd; subst; tcsp;[].
    applydup @inf_entry_extends_lib_cs_implies_matching in ilib'0; simpl in *.
    autorewrite with slow in *.

    dup ilib'1 as m.
    eapply two_entries_in_library_with_same_name in m; try exact ilib; simpl; eauto;[].
    subst e; simpl in *; repnd; GC.
    unfold inf_choice_sequence_entry_extend in *; simpl in *; repnd.
    unfold inf_choice_sequence_vals_extend in *; simpl in *.
    unfold choice_seq_vals2inf in *; simpl in *.
    unfold restriction2default in *.
    unfold same_restrictions in srestr.
    destruct restr; simpl in *; repnd; tcsp.

    assert (forall v, LIn v l -> v = 0) as h.
    {
      introv q.
      apply in_nth in q; exrepnd.
      pose proof (ilib'0 n0 (mkc_nat v)) as q.
      rewrite select_map in q.
      autodimp q hyp.
      { erewrite nth_select1; auto; unfold option_map; rewrite q0 at 1; eauto. }
      autorewrite with slow in q.
      rewrite select_ntimes in q; boolvar.

      { rewrite mkc_zero_eq in q.
        apply mkc_nat_eq_implies in q; auto. }

      { rewrite srestr0 in q; unfold natSeq2default in q; autorewrite with slow in q.
        rewrite mkc_zero_eq in q.
        apply mkc_nat_eq_implies in q; auto. }
    }

    clear ilib'0 ilib'.
    exists (length l); eauto 3 with slow.

  - unfold entry_in_inf_library_default in ilib'0; simpl in *; repnd; GC.
    unfold correct_restriction in *.
    rewrite ck in *; simpl in *.

    unfold is_default_choice_sequence in *.
    destruct restr0; simpl in *; repnd; tcsp.
    exists (length l).
    apply implies_list_eq_ntimes.
    introv i.
    apply in_nth in i; exrepnd.
    pose proof (ilib'0 n0 (mkc_nat v)) as q.
    rewrite select_map in q.
    autodimp q hyp.
    { erewrite nth_select1; auto; unfold option_map; rewrite i0 at 1; eauto. }
    rewrite safe2 in q; try omega.
    rewrite mkc_zero_eq in q.
    apply mkc_nat_eq_implies in q; auto.
Qed.

Lemma iscvalue_mkc_one {o} :
  @iscvalue o mkc_one.
Proof.
  repeat constructor; simpl; tcsp.
Qed.
Hint Resolve iscvalue_mkc_one : slow.

Lemma mk_nat_eq_implies {o} :
  forall n m, @mk_nat o n = mk_nat m -> n = m.
Proof.
  introv h.
  inversion h as [q].
  apply Znat.Nat2Z.inj in q; auto.
Qed.

Lemma computes_to_valc_apply_choice_seq_implies_find_cs_value_at_some {o} :
  forall lib name (a : @CTerm o) n v,
    computes_to_valc lib (mkc_eapply (mkc_choice_seq name) a) v
    -> computes_to_valc lib a (mkc_nat n)
    -> exists val, find_cs_value_at lib name n = Some val.
Proof.
  introv comp ca.
  destruct_cterms; simpl in *.
  unfold computes_to_valc in *; simpl in *.
  unfold computes_to_value in comp; repnd.
  unfold reduces_to in *; exrepnd.
  pose proof (reduces_in_atmost_k_steps_eapply_choice_seq_to_isvalue_like lib name x k x0) as q.
  repeat (autodimp q hyp); eauto 3 with slow.
  repndors; exrepnd; simpl in *; tcsp.

  {
    apply reduces_in_atmost_k_steps_implies_computes_to_value in q2; eauto 3 with slow.
    eapply computes_to_value_eq in q2; try exact ca.
    apply mk_nat_eq_implies in q2; subst.
    exists val; auto.
  }

  {
    apply isvalue_implies in comp; repnd.
    apply iscan_implies in comp0; exrepnd; subst; simpl in *; tcsp.
  }
Qed.

Lemma computes_to_valc_apply_choice_seq_implies_eapply {o} :
  forall lib name (a v : @CTerm o),
    computes_to_valc lib (mkc_apply (mkc_choice_seq name) a) v
    -> computes_to_valc lib (mkc_eapply (mkc_choice_seq name) a) v.
Proof.
  introv comp.
  destruct_cterms; unfold computes_to_valc in *; simpl in *.
  unfold computes_to_value in *; repnd; dands; auto.
  apply reduces_to_split2 in comp0; repndors; subst; simpl in *; tcsp.

  { inversion comp; subst; simpl in *; tcsp. }

  exrepnd.
  csunf comp0; simpl in comp0; ginv; auto.
Qed.
Hint Resolve computes_to_valc_apply_choice_seq_implies_eapply : slow.

Lemma not_exists_1_choice {o} :
  forall (lib : @library o) name v n restr,
    csn_kind name = cs_kind_seq []
    -> same_restrictions restr (csc_seq [])
    -> entry_in_library (lib_cs name (MkChoiceSeqEntry _ (ntimes n mkc_zero) restr)) lib
    -> safe_library lib
    -> inhabited_type lib (exists_1_choice name v)
    -> False.
Proof.
  introv ck srestr ilib safe inh.
  unfold exists_1_choice in inh.
  apply inhabited_exists in inh; exrepnd.
  clear inh0 inh1.
  rename inh2 into inh.

  unfold all_in_ex_bar in inh; exrepnd.

  assert (exists n restr lib',
             lib_extends lib' lib
             /\ bar_lib_bar bar lib'
             /\ same_restrictions restr (csc_seq [])
             /\ entry_in_library (lib_cs name (MkChoiceSeqEntry _ (ntimes n mkc_zero) restr)) lib') as blib.
  {
    pose proof (fresh_choice_seq_name_in_library lib []) as h; exrepnd.
    pose proof (bar_lib_bars bar (library2inf lib (simple_inf_choice_seq name0))) as q.
    autodimp q hyp; eauto 3 with slow;[].
    exrepnd.
    applydup q2 in ilib.

    apply entry_in_library_extends_implies_entry_in_library in ilib0; exrepnd.
    assert (safe_library_entry entry') as safe' by eauto 3 with slow.

    assert (name <> name0) as dname.
    { introv xx; subst name0.
      apply entry_in_library_implies_find_cs_some in ilib.
      rewrite ilib in *; ginv. }

    pose proof (entry_extends_cs_zeros_implies lib name name0 n restr lib' entry') as q.
    repeat (autodimp q hyp).
    exrepnd; subst.
    exists n0 restr0 lib'; dands; auto.
  }

  clear n restr srestr ilib.
  exrepnd.
  assert (safe_library lib') as safe' by eauto 3 with slow.
  pose proof (inh0 _ blib2 _ (lib_extends_refl lib')) as inh0.
  cbv beta in inh0.

  clear lib bar safe blib1 blib2.
  rename lib' into lib.
  rename safe' into safe.
  exrepnd.
  autorewrite with slow in *.

  apply member_tnat_iff in inh2.
  apply equality_in_mkc_equality in inh0; repnd.
  clear inh4 inh0.
  apply equality_in_tnat in inh3.
  unfold equality_of_nat_bar in inh3.
  unfold equality_of_nat in inh3.

  unfold all_in_ex_bar in *; exrepnd.
  apply (implies_all_in_bar_intersect_bars_left _ bar) in inh3.
  apply (implies_all_in_bar_intersect_bars_right _ bar0) in inh0.
  remember (intersect_bars bar0 bar) as bar1.
  clear bar0 bar Heqbar1.
  rename bar1 into bar.

  assert (exists n restr lib',
             lib_extends lib' lib
             /\ bar_lib_bar bar lib'
             /\ same_restrictions restr (csc_seq [])
             /\ entry_in_library (lib_cs name (MkChoiceSeqEntry _ (ntimes n mkc_zero) restr)) lib') as blib.
  {
    pose proof (fresh_choice_seq_name_in_library lib []) as h; exrepnd.
    pose proof (bar_lib_bars bar (library2inf lib (simple_inf_choice_seq name0))) as q.
    autodimp q hyp; eauto 3 with slow;[].
    exrepnd.
    applydup q2 in blib0.

    apply entry_in_library_extends_implies_entry_in_library in blib1; exrepnd.
    assert (safe_library_entry entry') as safe' by eauto 3 with slow.

    assert (name <> name0) as dname.
    { introv xx; subst name0.
      apply entry_in_library_implies_find_cs_some in blib0.
      rewrite blib0 in *; ginv. }

    pose proof (entry_extends_cs_zeros_implies lib name name0 n restr lib' entry') as q.
    repeat (autodimp q hyp).
    exrepnd; subst.
    exists n0 restr0 lib'; dands; auto.
  }

  clear n restr blib3 blib0.
  exrepnd.
  assert (safe_library lib') as safe' by eauto 3 with slow.
  pose proof (inh0 _ blib2 _ (lib_extends_refl lib')) as inh0.
  pose proof (inh3 _ blib2 _ (lib_extends_refl lib')) as inh3.
  cbv beta in inh0, inh3.

  clear lib bar safe blib1 blib2 inh1.
  rename lib' into lib.
  rename safe' into safe.
  exrepnd; spcast.
  apply computes_to_valc_isvalue_eq in inh1; eauto 3 with slow.
  rewrite <- inh1 in *.
  clear dependent k.

  pose proof (implies_compute_to_valc_apply_choice_seq lib a name k0 mkc_zero) as q.
  repeat (autodimp q hyp); eauto 3 with slow; try computes_to_eqval.

  pose proof (computes_to_valc_apply_choice_seq_implies_find_cs_value_at_some lib name a k0 mkc_one) as w.
  repeat (autodimp w hyp); eauto 3 with slow;[]; exrepnd.

  apply entry_in_library_implies_find_cs_some in blib0.
  unfold find_cs_value_at in *.
  rewrite blib0 in *.
  simpl in *.
  rewrite find_value_of_cs_at_vals_as_select.
  rewrite find_value_of_cs_at_vals_as_select in w0.
  rewrite select_ntimes in *.
  rewrite select_ntimes in w0.
  boolvar; tcsp.
Qed.




(* end hide*)

(**

  Using the axiom of excluded middle from [Classical_Prop], we can
  easily prove the following squashed excluded middle rule:
<<
   H |- squash(P \/ ~P) ext Ax

     By SquashedEM

     H |- P in Type(i) ext Ax
>>

  where [mk_squash] is defined as
  [Definition mk_squash T := mk_image T (mk_lam nvarx mk_axiom)], i.e.,
  we map all the elements of [T] to [mk_axiom].
  The only inhabitant of [mk_squash T] is [mk_axiom],
  and we can prove that [mkc_axiom] is a member of [mkc_squash T] iff
  [T] is inhabited.  However, in the theory, there is in general no
  way to know which terms inhabit [T].

 *)

Definition rule_squashed_excluded_middle {o}
           (P : NVar)
           (i : nat)
           (H : @barehypotheses o) :=
  mk_rule
    (mk_baresequent H (mk_conclax (mk_not (mk_all (mk_uni i) P (mk_squash (mk_or (mk_var P) (mk_not (mk_var P))))))))
    []
    [].

Lemma rule_squashed_excluded_middle_true {o} :
  forall lib (P : NVar) (i : nat) (H : @bhyps o) (safe : safe_library lib),
    rule_true lib (rule_squashed_excluded_middle P i H).
Proof.
  unfold rule_squashed_excluded_middle, rule_true, closed_type_baresequent, closed_extract_baresequent; simpl.
  intros.
  clear cargs hyps.

  (* We prove the well-formedness of things *)
  destseq; allsimpl.
  dLin_hyp.
  destseq; allsimpl; proof_irr; GC.

  unfold closed_extract; simpl.

  exists (@covered_axiom o (nh_vars_hyps H)).

  (* We prove some simple facts on our sequents *)
  (* xxx *)
  (* done with proving these simple facts *)

  vr_seq_true.
  unfold mk_all.
  lsubst_tac.
  rw @tequality_not.
  rw @equality_in_not.
  rw @tequality_function.

  dands; eauto 3 with slow.

  {
    introv ext' eu.
    repeat lsubstc_vars_as_mkcv.
    autorewrite with slow.
    apply tequality_mkc_squash.
    apply tequality_mkc_or; dands; eauto 3 with slow;[].

    pose proof (lsubstc_vars_mk_not_as_mkcv (mk_var P) w4 (csub_filter s1 [P]) [P] c8) as q; exrepnd.
    eapply tequality_respects_alphaeqc_left;
      [apply alphaeqc_sym;apply substc_alphaeqcv;exact q1
      |].
    clear q1.

    pose proof (lsubstc_vars_mk_not_as_mkcv (mk_var P) w4 (csub_filter s2 [P]) [P] c10) as q; exrepnd.
    eapply tequality_respects_alphaeqc_right;
      [apply alphaeqc_sym;apply substc_alphaeqcv;exact q1
      |].
    clear q1.

    autorewrite with slow.
    apply tequality_not; eauto 3 with slow.
  }

  {
    unfold type.
    rw @tequality_function; dands; eauto 3 with slow.
    introv ext' eu.
    repeat lsubstc_vars_as_mkcv.
    autorewrite with slow.
    apply tequality_mkc_squash.
    apply tequality_mkc_or; dands; eauto 3 with slow;[].

    pose proof (lsubstc_vars_mk_not_as_mkcv (mk_var P) w2 (csub_filter s1 [P]) [P] c7) as q; exrepnd.
    eapply tequality_respects_alphaeqc_left;
      [apply alphaeqc_sym;apply substc_alphaeqcv;exact q1
      |].
    eapply tequality_respects_alphaeqc_right;
      [apply alphaeqc_sym;apply substc_alphaeqcv;exact q1
      |].
    clear q1.

    autorewrite with slow.
    apply tequality_not; eauto 3 with slow.
  }

  introv ext' inh.
  rw @inhabited_function in inh; exrepnd.
  clear inh0 inh1.

  assert (safe_library lib'0) as safe' by eauto 3 with slow.

  (* WARNING *)
  clear lib lib' ext sim eqh ext' safe.
  rename lib'0 into lib.
  rename safe' into safe.

  pose proof (fresh_choice_seq_name_in_library lib []) as w; exrepnd.
  assert (is_nat_or_seq_kind name) as isn.
  eauto 3 with slow.

  pose proof (inh2 (choice_sequence_name2entry name :: lib)) as q.
  clear inh2.
  autodimp q hyp; eauto 3 with slow.

  pose proof (q (exists_1_choice name nvarx) (exists_1_choice name nvarx)) as q.
  autodimp q hyp.

  {
    unfold exists_1_choice.
    apply equality_product; dands; eauto 3 with slow.
    introv ext ea.
    autorewrite with slow.

    apply equality_int_nat_implies_cequivc in ea.
    apply ccequivc_ext_bar_iff_ccequivc_bar in ea.
    apply all_in_ex_bar_equality_implies_equality.
    eapply all_in_ex_bar_modus_ponens1;[|exact ea]; clear ea; introv y ea; exrepnd; spcast.

    apply equality_mkc_equality2_sp_in_uni; dands; eauto 3 with slow.
    split; exists (trivial_bar lib'0); apply in_ext_implies_all_in_bar_trivial_bar;
      introv ext'; right; eauto 3 with slow.
  }

  repeat lsubstc_vars_as_mkcv.
  autorewrite with slow in q.
  apply equality_in_mkc_squash in q; repnd.
  clear q0 q1.

  remember (choice_sequence_name2entry name :: lib) as lib'.
  assert (entry_in_library (choice_sequence_name2entry name) lib') as eil by (subst; tcsp).
  assert (safe_library lib') as safe' by (subst; eauto 3 with slow).

  clear lib w4 Heqlib' safe.
  rename lib' into lib.
  rename safe' into safe.

  (* XXXXXXXXXXXXX *)
  unfold inhabited_type_bar, all_in_ex_bar in q; exrepnd.

  assert (exists n restr lib',
             lib_extends lib' lib
             /\ bar_lib_bar bar lib'
             /\ same_restrictions restr (csc_seq [])
             /\ entry_in_library (lib_cs name (MkChoiceSeqEntry _ (ntimes n mkc_zero) restr)) lib') as blib.
  {
    pose proof (fresh_choice_seq_name_in_library lib []) as h; exrepnd.
    pose proof (bar_lib_bars bar (library2inf lib (simple_inf_choice_seq name0))) as q.
    autodimp q hyp; eauto 3 with slow;[].
    exrepnd.
    applydup q3 in eil.

    apply entry_in_library_extends_implies_entry_in_library in eil0; exrepnd.
    assert (safe_library_entry entry') as safe' by eauto 3 with slow.

    assert (name <> name0) as dname.
    { introv xx; subst name0.
      apply entry_in_library_implies_find_cs_some in eil.
      rewrite eil in *; ginv. }

    pose proof (entry_extends_choice_sequence_name2entry_implies lib name name0 lib' entry') as q.
    repeat (autodimp q hyp);[].
    exrepnd; subst.
    exists n restr lib'; dands; auto.
  }

  exrepnd.
  pose proof (q0 _ blib2 _ (lib_extends_refl lib')) as q0.
  cbv beta in q0.

  assert (safe_library lib') as safe' by eauto 3 with slow.
  clear lib bar eil safe blib1 blib2.
  rename lib' into lib.
  rename safe' into safe.

  unfold inhabited_type in q0; exrepnd.
  apply equality_mkc_or in q1; repnd.
  clear q0 q2.
  rename q1 into q.

  (* XXXXXXXXXXXXX *)
  unfold all_in_ex_bar in q; exrepnd.

  assert (exists n restr lib',
             lib_extends lib' lib
             /\ bar_lib_bar bar lib'
             /\ same_restrictions restr (csc_seq [])
             /\ entry_in_library (lib_cs name (MkChoiceSeqEntry _ (ntimes n mkc_zero) restr)) lib') as blib.
  {
    pose proof (fresh_choice_seq_name_in_library lib []) as h; exrepnd.
    pose proof (bar_lib_bars bar (library2inf lib (simple_inf_choice_seq name0))) as q.
    autodimp q hyp; eauto 3 with slow;[].
    exrepnd.
    applydup q3 in blib0.

    apply entry_in_library_extends_implies_entry_in_library in blib1; exrepnd.
    assert (safe_library_entry entry') as safe' by eauto 3 with slow.

    assert (name <> name0) as dname.
    { introv xx; subst name0.
      apply entry_in_library_implies_find_cs_some in blib0.
      rewrite blib0 in *; ginv. }

    pose proof (entry_extends_cs_zeros_implies lib name name0 n restr lib' entry') as q.
    repeat (autodimp q hyp);[].
    exrepnd; subst.
    exists n0 restr0 lib'; dands; auto.
  }

  clear n restr blib3 blib0.
  exrepnd.
  assert (safe_library lib') as safe' by eauto 3 with slow.
  pose proof (q0 _ blib2 _ (lib_extends_refl lib')) as q0.
  cbv beta in q0.

  clear lib bar safe blib1 blib2.
  rename lib' into lib.
  rename safe' into safe.

  repndors; exrepnd;[|].

  {
    clear q1 q2.
    rename q0 into q.
    assert (inhabited_type lib (exists_1_choice name nvarx)) as inh.
    { exists a1; eapply equality_refl; eauto. }
    eapply not_exists_1_choice in inh; eauto.
  }

  {
    
  }


XXXXXXXXX
  eapply non_dep_all_in_ex_bar_implies.
  eapply all_in_ex_bar_modus_ponens1;[|exact q]; clear q; introv y q; exrepnd; spcast.
  unfold inhabited_type in q; exrepnd.
  apply equality_mkc_or in q0; repnd.
  clear q1 q2.

Qed.
