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

  Authors: Abhishek Anand & Vincent Rahli

*)


Require Export per_props_uni0.


Lemma either_computes_to_equality_mkc_cequiv_false {o} :
  forall lib (a b c d : @CTerm o),
    either_computes_to_equality lib (mkc_cequiv a b) (mkc_cequiv c d) -> False.
Proof.
  introv e.
  unfold either_computes_to_equality, computes_to_equality in e.
  repndors; exrepnd; spcast; computes_to_value_isvalue.
Qed.

Lemma equal_equality_types_mkc_cequiv {o} :
  forall lib ts (a b c d : @CTerm o),
    equal_equality_types lib ts (mkc_cequiv a b) (mkc_cequiv c d).
Proof.
  introv e.
  apply either_computes_to_equality_mkc_cequiv_false in e; tcsp.
Qed.
Hint Resolve equal_equality_types_mkc_cequiv : slow.

Lemma either_computes_to_equality_mkc_approx_false {o} :
  forall lib (a b c d : @CTerm o),
    either_computes_to_equality lib (mkc_approx a b) (mkc_approx c d) -> False.
Proof.
  introv e.
  unfold either_computes_to_equality, computes_to_equality in e.
  repndors; exrepnd; spcast; computes_to_value_isvalue.
Qed.

Lemma equal_equality_types_mkc_approx {o} :
  forall lib ts (a b c d : @CTerm o),
    equal_equality_types lib ts (mkc_approx a b) (mkc_approx c d).
Proof.
  introv e.
  apply either_computes_to_equality_mkc_approx_false in e; tcsp.
Qed.
Hint Resolve equal_equality_types_mkc_approx : slow.

Lemma either_computes_to_equality_mkc_base_false {o} :
  forall lib, @either_computes_to_equality o lib mkc_base mkc_base -> False.
Proof.
  introv e.
  unfold either_computes_to_equality, computes_to_equality in e.
  repndors; exrepnd; spcast; computes_to_value_isvalue.
Qed.

Lemma equal_equality_types_mkc_base {o} :
  forall lib ts, @equal_equality_types o lib ts mkc_base mkc_base.
Proof.
  introv e.
  apply either_computes_to_equality_mkc_base_false in e; tcsp.
Qed.
Hint Resolve equal_equality_types_mkc_base : slow.

Lemma mkc_cequiv_equality_in_uni {o} :
  forall lib (a b c d : @CTerm o) i,
    equality lib (mkc_cequiv a b) (mkc_cequiv c d) (mkc_uni i)
    <=>
    (ccequivc lib a b <=> ccequivc lib c d).
Proof.
  sp; sp_iff Case; intro e.

  - Case "->".
    unfold equality in e; exrepnd.
    allunfold @nuprl.
    inversion e1; try not_univ.
    duniv j h.
    allrw @univi_exists_iff; exrepnd.
    computes_to_value_isvalue; GC.
    rw h0 in e0; clear h0.
    unfold univi_eq in e0; exrepnd.
    dextts e2 ts1 ts2 ext.
    clear ext.
    inversion ts1; try not_univ; clear ts1.
    inversion ts2; try not_univ; clear ts2.
    match goal with
    | [ H1 : per_cequiv _ _ _ _ , H2 : per_cequiv _ _ _ _ |- _ ] =>
      rename H1 into h; rename H2 into q
    end.
    unfold per_cequiv in *; exrepnd.
    computes_to_value_isvalue; GC.
    eapply eq_term_equals_trans in q1;[|apply eq_term_equals_sym;exact h2].
    pose proof (q1 (@mkc_axiom o) (@mkc_axiom o)) as w; simpl in w; auto.

  - Case "<-".
    exists (univi_eq lib (univi lib i)); sp; eauto 2 with slow.
    exists (fun (_ _ : @CTerm o) => ccequivc lib a b).
    split; eauto 2 with slow; apply CL_cequiv; unfold per_cequiv;
      [exists a b|exists c d];
      sp; spcast; try computes_to_value_refl.
    introv z w; auto.
Qed.

Lemma mkc_approx_equality_in_uni {o} :
  forall lib (a b c d : @CTerm o) i,
    equality lib (mkc_approx a b) (mkc_approx c d) (mkc_uni i)
    <=>
    (capproxc lib a b <=> capproxc lib c d).
Proof.
  sp; sp_iff Case; intro e.

  - Case "->".
    unfold equality in e; exrepnd.
    allunfold @nuprl.
    inversion e1; try not_univ.
    duniv j h.
    allrw @univi_exists_iff; exrepnd.
    computes_to_value_isvalue; GC.
    rw h0 in e0; clear h0.
    unfold univi_eq in e0; exrepnd.
    dextts e2 ts1 ts2 ext; clear ext.
    inversion ts1; try not_univ; clear ts1.
    inversion ts2; try not_univ; clear ts2.
    match goal with
    | [ H1 : per_approx _ _ _ _ , H2 : per_approx _ _ _ _ |- _ ] =>
      rename H1 into h; rename H2 into q
    end.
    unfold per_approx in *; exrepnd.
    computes_to_value_isvalue; GC.
    eapply eq_term_equals_trans in q1;[|apply eq_term_equals_sym;exact h2].
    pose proof (q1 (@mkc_axiom o) (@mkc_axiom o)) as w; simpl in w; auto.

  - Case "<-".
    exists (univi_eq lib (univi lib i)); sp; eauto 2 with slow.
    exists (fun (_ _ : @CTerm o) => capproxc lib a b).
    split; eauto 2 with slow; apply CL_approx; unfold per_approx;
      [exists a b|exists c d];
      sp; spcast; try computes_to_value_refl.
    introv z w; auto.
Qed.

Hint Resolve approxc_refl : slow.

Lemma member_approx_refl {p} :
  forall lib t, @member p lib mkc_axiom (mkc_approx t t).
Proof.
  intros.
  unfold member, equality.
  exists (fun (a b : @CTerm p) => capproxc lib t t).
  unfold nuprl; sp; spcast; try computes_to_value_refl; eauto 2 with slow.
  apply CL_approx.
  unfold per_approx.
  exists t t; sp; spcast; computes_to_value_refl.
Qed.

Lemma member_cequiv_refl {p} :
  forall lib t, @member p lib mkc_axiom (mkc_cequiv t t).
Proof.
  intros.
  unfold member, equality.
  exists (fun (a b : @CTerm p) => ccequivc lib t t).
  unfold nuprl; sp; spcast; try computes_to_value_refl; sp.
  apply CL_cequiv.
  unfold per_cequiv.
  exists t t; sp; spcast; try computes_to_value_refl.
Qed.

Lemma equal_approx {p} :
  forall lib t u,
    @tequality p lib (mkc_approx t t) (mkc_approx u u).
Proof.
  intros.
  unfold tequality.
  exists (fun (a b : @CTerm p) => capproxc lib t t).
  split; eauto 2 with slow; apply CL_approx; [exists t t|exists u u];
    sp; spcast; try computes_to_value_refl.
  introv z w; split; sp; spcast; apply approxc_refl; sp.
Qed.

Lemma equal_cequiv {p} :
  forall lib t u,
    @tequality p lib (mkc_cequiv t t) (mkc_cequiv u u).
Proof.
  intros.
  unfold tequality.
  exists (fun (a b : @CTerm p) => ccequivc lib t t).
  split; eauto 2 with slow; apply CL_cequiv; [exists t t|exists u u];
    sp; spcast; try computes_to_value_refl;
  try (split; sp; spcast; sp).
Qed.

Lemma member_base {p} :
  forall lib t, @member p lib t mkc_base.
Proof.
  unfold member, equality; sp.
  exists (fun t t' => @ccequivc p lib t t').
  unfold nuprl; sp; spcast; sp.
  apply CL_base.
  unfold per_base; sp; spcast; try computes_to_value_refl.
Qed.
Hint Resolve member_base : slow.

Lemma member_cequiv {p} :
  forall lib t1 t2,
    @cequivc p lib t1 t2
    -> member lib mkc_axiom (mkc_cequiv t1 t2).
Proof.
  unfold member, equality; sp.
  exists (fun (t t' : @CTerm p) => ccequivc lib t1 t2);
    sp; spcast; try computes_to_value_refl; sp.
  apply CL_cequiv.
  unfold per_cequiv.
  exists t1 t2; sp; spcast; try computes_to_value_refl.
Qed.

Lemma member_approx {p} :
  forall lib t1 t2,
    @approxc p lib t1 t2
    -> member lib mkc_axiom (mkc_approx t1 t2).
Proof.
  unfold member, equality; sp.
  exists (fun (t t' : @CTerm p) => capproxc lib t1 t2);
    sp; spcast; try computes_to_value_refl; sp.
  apply CL_approx.
  unfold per_approx.
  exists t1 t2; sp; spcast; try computes_to_value_refl.
Qed.

Lemma member_approx_iff {p} :
  forall lib (t1 t2 : @CTerm p),
    capproxc lib t1 t2
    <=> member lib mkc_axiom (mkc_approx t1 t2).
Proof.
  sp; split; intro e.
  spcast; apply member_approx; sp.
  allunfold @member; allunfold @equality; allunfold @nuprl; exrepnd.
  inversion e1; subst; try not_univ.

  match goal with
  | [ H1 : per_approx _ _ _ _  |- _ ] => rename H1 into h
  end.

  allunfold @per_approx; exrepnd.
  uncast; computes_to_value_isvalue.
  apply h1 in e0; auto.
Qed.

Lemma member_halts_iff {p} :
  forall lib (t : @CTerm p),
    chaltsc lib t
    <=> member lib mkc_axiom (mkc_halts t).
Proof.
  sp; rewrite <- fold_mkc_halts.
  generalize (member_approx_iff lib mkc_axiom (mkc_cbv t nvarx (mkcv_axiom nvarx))) as i; sp.
  rw <- i; clear i.
  destruct t; unfold hasvaluec, approxc, mkc_cbv; simpl.

  sp_iff Case.

  - Case "->".
    intro hv.
    spcast; allunfold @approxc; allunfold @hasvaluec; allsimpl.
    allrw @isprog_eq.
    generalize (hasvalue_as_approx lib x i); intro e.
    allrw <-; sp.

  - Case "<-".
    intro a; spcast; allunfold @approxc; allunfold @hasvaluec; allsimpl.
    allrw @isprog_eq.
    generalize (hasvalue_as_approx lib x i); intro e.
    allrw; sp.
Qed.

Lemma equality_in_base {p} :
  forall lib (t1 t2 : @CTerm p),
    equality lib t1 t2 mkc_base -> ccequivc lib t1 t2.
Proof.
  unfold equality, nuprl; introv e; exrepnd.
  inversion e1; subst; try not_univ.

  match goal with
  | [ H1 : per_base _ _ _ _  |- _ ] => rename H1 into h
  end.

  allunfold @per_base; exrepnd.
  apply h in e0; auto.
Qed.

Lemma equality_in_base_iff {p} :
  forall lib (t1 t2 : @CTerm p),
    equality lib t1 t2 mkc_base <=> ccequivc lib t1 t2.
Proof.
  intros; split; intro i; try (apply equality_in_base; sp).
  unfold equality, nuprl.
  exists (fun a b : @CTerm p => ccequivc lib a b); sp.
  apply CL_base; unfold per_base; sp;
  spcast; apply computes_to_value_isvalue_refl; repeat constructor; simpl; sp.
Qed.

Lemma tequality_base {p} :
  forall lib, @tequality p lib mkc_base mkc_base.
Proof.
  introv.
  unfold tequality.
  exists (fun a b : @CTerm p => ccequivc lib a b).
  split; eauto 2 with slow; apply CL_base; unfold per_base; sp; spcast;
    try (apply computes_to_valc_refl);
    try (apply iscvalue_mkc_base; auto).
Qed.
Hint Immediate tequality_base.

Hint Resolve iscvalue_mkc_cequiv : slow.
Hint Resolve iscvalue_mkc_approx : slow.

Lemma tequality_mkc_approx {o} :
  forall lib (a b c d : @CTerm o),
    tequality lib (mkc_approx a b) (mkc_approx c d)
    <=>
    (capproxc lib a b <=> capproxc lib c d).
Proof.
  unfold tequality, nuprl; sp; split; intro k; exrepnd.

  { destruct k0 as [k1 k2].
    inversion k1; subst; try not_univ; clear k1.
    inversion k2; subst; try not_univ; clear k2.

    match goal with
    | [ H1 : per_approx _ _ _ _ , H2 : per_approx _ _ _ _ |- _ ] =>
      rename H1 into h; rename H2 into q
    end.

    unfold per_approx in *; exrepnd; computes_to_value_isvalue.
    eapply eq_term_equals_trans in q1;[|apply eq_term_equals_sym;exact h1].
    pose proof (q1 (@mkc_axiom o) (@mkc_axiom o)) as h; simpl in h; auto. }

  { exists (fun x y : @CTerm o => capproxc lib a b).
    split; eauto 2 with slow; apply CL_approx; unfold per_approx;
      [exists a b|exists c d]; sp; tcsp; spcast;
        try (apply computes_to_valc_refl; eauto 2 with slow).
    introv z w; auto. }
Qed.

Lemma chasvaluec_as_capproxc {p} :
  forall lib (a : @CTerm p),
    chaltsc lib a
    <=>
    capproxc lib mkc_axiom (mkc_cbv a nvarx (mkcv_axiom nvarx)).
Proof.
  introv; split; intro k; spcast.
  rw <- @hasvaluec_as_approxc; sp.
  allrw @hasvaluec_as_approxc; sp.
Qed.

Lemma tequality_mkc_halts {p} :
  forall lib (a b : @CTerm p),
    tequality lib (mkc_halts a) (mkc_halts b)
    <=>
    (chaltsc lib a <=> chaltsc lib b).
Proof.
  intros; repeat (rewrite <- fold_mkc_halts).
  rw @tequality_mkc_approx.
  allrw @chasvaluec_as_capproxc; sp.
Qed.

(*
Lemma tequality_mkc_halts :
  forall a b,
    tequality lib (mkc_halts a) (mkc_halts b)
    <->
    (hasvaluec a <-> hasvaluec b).
Proof.
  sp.
  repeat (rewrite <- fold_mkc_halts).
  rewrite tequality_mkc_approx.
  repeat (rewrite <- hasvaluec_as_approxc); sp.
Qed.
*)

(*
Lemma member_approx_is_axiom {p} :
  forall lib (t t1 t2 : @CTerm p),
    member lib t (mkc_approx t1 t2)
    -> t ===>(lib) mkc_axiom.
Proof.
  introv m.
  unfold member, equality, nuprl in m; exrepnd.
  inversion m1; subst; try not_univ.
  allunfold @per_approx; exrepnd.
  discover; sp.
Qed.
*)

Lemma member_cequiv_iff {p} :
  forall lib (t1 t2 : @CTerm p),
    ccequivc lib t1 t2
    <=> member lib mkc_axiom (mkc_cequiv t1 t2).
Proof.
  sp; split; intro e.
  spcast; apply member_cequiv; sp.
  allunfold @member; allunfold @equality; allunfold @nuprl; exrepnd.
  inversion e1; subst; try not_univ.

  match goal with
  | [ H1 : per_cequiv _ _ _ _  |- _ ] => rename H1 into h
  end.

  allunfold @per_cequiv; exrepnd.
  uncast; computes_to_value_isvalue.
  apply h1 in e0; auto.
Qed.

Lemma tequality_mkc_cequiv {o} :
  forall lib (a b c d : @CTerm o),
    tequality lib (mkc_cequiv a b) (mkc_cequiv c d)
    <=>
    (ccequivc lib a b <=> ccequivc lib c d).
Proof.
  unfold tequality, nuprl; sp; split; intro k; exrepnd.

  { destruct k0 as [k1 k2].
    inversion k1; subst; try not_univ; clear k1.
    inversion k2; subst; try not_univ; clear k2.

    match goal with
    | [ H1 : per_cequiv _ _ _ _ , H2 : per_cequiv _ _ _ _ |- _ ] =>
      rename H1 into h; rename H2 into q
    end.

    unfold per_cequiv in *; exrepnd; computes_to_value_isvalue.
    eapply eq_term_equals_trans in q1;[|apply eq_term_equals_sym;exact h1].
    pose proof (q1 (@mkc_axiom o) (@mkc_axiom o)) as h; simpl in h; auto. }

  { exists (fun x y : @CTerm o => ccequivc lib a b).
    split; eauto 2 with slow; apply CL_cequiv; [exists a b|exists c d]; sp;
      spcast; try (apply computes_to_valc_refl; eauto 2 with slow).
    introv z w; auto. }
Qed.

Lemma equality_in_approx {o} :
  forall lib (a b t1 t2 : @CTerm o),
    capproxc lib t1 t2
    <=> equality lib a b (mkc_approx t1 t2).
Proof.
  sp; split; intro e.

  - unfold member, equality; sp.
    exists (fun t t' : @CTerm o => capproxc lib t1 t2);
      sp; spcast; try computes_to_value_refl; sp.
    apply CL_approx.
    unfold per_approx.
    exists t1 t2; sp; spcast; try computes_to_value_refl.

  - unfold equality, nuprl in e; exrepnd.
    inversion e1; subst; try not_univ.

    match goal with
    | [ H1 : per_approx _ _ _ _ |- _ ] => rename H1 into h
    end.

    allunfold @per_approx; exrepnd.
    uncast; computes_to_value_isvalue.
    apply h1 in e0; auto.
Qed.

Lemma equality_in_mkc_cequiv {o} :
  forall lib a b (t1 t2 : @CTerm o),
    equality lib a b (mkc_cequiv t1 t2)
    <=> ccequivc lib t1 t2.
Proof.
  introv; split; intro h.

  - unfold equality, nuprl in h; exrepnd.
    inversion h1; subst; try not_univ.

    match goal with
    | [ H : per_cequiv _ _ _ _ |- _ ] => rename H into p
    end.

    allunfold @per_cequiv; exrepnd; uncast; computes_to_value_isvalue.
    apply p1 in h0; clear p1; repnd; uncast.
    dands; spcast; auto.

  - unfold equality.
    exists (fun (t t' : @CTerm o) => ccequivc lib t1 t2);
      sp; spcast; try computes_to_value_refl; sp.
    apply CL_cequiv.
    unfold per_cequiv.
    exists t1 t2; sp; spcast; try computes_to_value_refl.
Qed.

Lemma inhabited_cequiv {o} :
  forall lib (t1 t2 : @CTerm o),
    inhabited_type lib (mkc_cequiv t1 t2) <=> ccequivc lib t1 t2.
Proof.
  unfold inhabited_type.
  introv; split; intro h; exrepnd.
  - rw @equality_in_mkc_cequiv in h0; tcsp.
  - exists (@mkc_axiom o).
    apply member_cequiv_iff; auto.
Qed.

Lemma inhabited_halts {p} :
  forall lib (t : @CTerm p), chaltsc lib t <=> inhabited_type lib (mkc_halts t).
Proof.
  introv; split; intro h.

  { rw @member_halts_iff in h; exists (@mkc_axiom p); auto. }

  unfold inhabited_type in h; exrepnd.
  unfold member, equality in h0; exrepnd.
  rewrite <- fold_mkc_halts in h0.
  inversion h0; subst; try not_univ.

  match goal with
  | [ H1 : per_approx _ _ _ _ |- _ ] => rename H1 into q
  end.

  allunfold @per_approx; exrepnd.
  computes_to_value_isvalue.
  apply q1 in h1; exrepnd; spcast.
  destruct_cterms; allsimpl.
  unfold hasvaluec; simpl.
  allunfold @approxc; allsimpl.
  assert (isprogram x0) as isp by (apply isprogram_eq; auto).
  generalize (hasvalue_as_approx lib x0 isp); intro e.
  apply e; auto.
Qed.

Lemma type_mkc_halts {p} :
  forall lib (a : @CTerm p), type lib (mkc_halts a).
Proof.
  introv; rw <- @fold_type; rw @tequality_mkc_halts; sp.
Qed.
Hint Immediate type_mkc_halts.

Lemma equality_in_halts {p} :
  forall lib (a b t : @CTerm p),
    chaltsc lib t
    <=> equality lib a b (mkc_halts t).
Proof.
  introv; rewrite <- fold_mkc_halts; rw <- @equality_in_approx;
    split; intro k; repnd; spcast; dands; spcast; auto;
      destruct_cterms; allunfold @hasvaluec; allunfold @approxc; allsimpl;
        assert (isprogram x) as isp by (apply isprogram_eq; auto);
        generalize (hasvalue_as_approx lib x isp); intro e; apply e; auto.
Qed.

Lemma type_mkc_unit {p} : forall lib, @type p lib mkc_unit.
Proof.
  introv; rw @mkc_unit_eq.
  apply fold_type; apply equal_approx.
Qed.
Hint Immediate type_mkc_unit.
Hint Resolve type_mkc_unit : slow.

Lemma tequality_unit {o} :
  forall lib, @tequality o lib mkc_unit mkc_unit.
Proof.
  introv; allrw @mkc_unit_eq.
  rw @tequality_mkc_approx; sp.
Qed.

Lemma equality_in_unit {o} :
  forall lib (a b : @CTerm o),
    equality lib a b mkc_unit.
Proof.
  introv.
  allrw @mkc_unit_eq.
  rw <- @equality_in_approx; split; sp.
  spcast; sp.
  apply approxc_refl.
Qed.

Lemma resp_cvc_approxc {p} :
  forall lib, respects2 (computes_to_valc lib) (@approxc p lib).
Proof.
  split; introv Hc Ha;
  apply computes_to_valc_implies_approxc in Hc; repnd;
  destruct_cterms; allunfold @approxc;
  eauto with slow.
Qed.
Hint Resolve resp_cvc_approxc : respects.

Lemma equality_in_uni_mkc_halts {p} :
  forall lib i (a b : @CTerm p),
    equality lib (mkc_halts a) (mkc_halts b) (mkc_uni i)
    <=>
    (chaltsc lib a <=> chaltsc lib b).
Proof.
  intros; repeat (rewrite <- fold_mkc_halts).
  rw @mkc_approx_equality_in_uni.
  allrw @chasvaluec_as_capproxc; sp.
Qed.

Lemma cequorsq_mkc_halts_implies {p} :
  forall lib i (a b : @CTerm p),
    equorsq lib (mkc_halts a) (mkc_halts b) (mkc_uni i)
    -> (chaltsc lib a <=> chaltsc lib b).
Proof.
  unfold equorsq; intros; sp;
  allrw @equality_in_uni_mkc_halts; sp.
  uncast; allrw @cequivc_decomp_halts; sp;
  split; sp; spcast; discover; sp.
Qed.

Lemma cequorsq_mkc_halts {p} :
  forall lib i (a b : @CTerm p),
    equorsq lib (mkc_halts a) (mkc_halts b) (mkc_uni i)
    <=>
    (chaltsc lib a <=> chaltsc lib b).
Proof.
  unfold equorsq; intros; split; sp; try right;
  allrw @equality_in_uni_mkc_halts; sp; uncast;
  allrw @cequivc_decomp_halts; try split; sp; spcast;
  discover; sp.
Abort.
(* This is not true in Prop with Cast around hasvalue *)
(*Qed.*)

Lemma member_in_base_iff {o} :
  forall lib (t : @CTerm o), member lib t mkc_base <=> True.
Proof.
  intros; split; intro; auto; apply member_base.
Qed.

Lemma equality_in_base_true {o} :
  forall lib (t : @CTerm o), equality lib t t mkc_base.
Proof.
  introv.
  apply member_in_base_iff; auto.
Qed.
Hint Resolve equality_in_base_true : slow.
