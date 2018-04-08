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


Require Export type_sys.
Require Export dest_close.
Require Export per_ceq_bar.


Lemma per_nat_bar_uniquely_valued {p} :
  forall (ts : cts(p)), uniquely_valued (per_nat_bar ts).
Proof.
 unfold uniquely_valued, per_nat_bar, eq_term_equals; sp.
 allrw; sp.
Qed.
Hint Resolve per_nat_bar_uniquely_valued : slow.

Lemma per_nat_bar_type_extensionality {p} :
  forall (ts : cts(p)), type_extensionality (per_nat_bar ts).
Proof.
  unfold type_extensionality, per_nat_bar, eq_term_equals; sp.
  allrw <-; sp.
Qed.
Hint Resolve per_nat_bar_type_extensionality : slow.

Lemma per_nat_bar_type_symmetric {p} :
  forall (ts : cts(p)), type_symmetric (per_nat_bar ts).
Proof.
  unfold type_symmetric, per_nat_bar; sp.
  exists bar; dands; auto.
Qed.
Hint Resolve per_nat_bar_type_symmetric : slow.

Lemma equality_of_nat_sym {o} :
  forall lib (t1 t2 : @CTerm o),
    equality_of_nat lib t1 t2
    -> equality_of_nat lib t2 t1.
Proof.
  introv e; unfold equality_of_nat in *; exrepnd.
  exists n; auto.
Qed.
Hint Resolve equality_of_nat_sym : slow.

Lemma per_nat_bar_term_symmetric {p} :
  forall (ts : cts(p)), term_symmetric (per_nat_bar ts).
Proof.
  introv h e.
  unfold per_nat_bar in h; exrepnd.
  apply h in e; apply h.
  unfold equality_of_nat_bar in *; exrepnd; exists bar0.
  introv ie i; apply e0 in i; eauto 2 with slow.
Qed.
Hint Resolve per_nat_bar_term_symmetric : slow.

Lemma cequivc_Nat {o} :
  forall lib (T T' : @CTerm o),
    computes_to_valc lib T mkc_Nat
    -> cequivc lib T T'
    -> computes_to_valc lib T' mkc_Nat.
Proof.
  sp.
  allapply @computes_to_valc_to_valuec; allsimpl.
  apply cequivc_canonical_form with (t' := T') in X; sp.
  apply lblift_cequiv0 in p; subst; auto.
Qed.
Hint Resolve cequivc_Nat : slow.

Lemma per_nat_bar_type_value_respecting {p} :
  forall (ts : cts(p)), type_value_respecting (per_nat_bar ts).
Proof.
  introv per ceq.
  unfold type_value_respecting, per_nat_bar in *; exrepnd; GC.
  dands; auto;[].
  exists bar; dands; auto.
  introv ie i.
  applydup per0 in i; auto.
  assert (lib_extends lib'0 lib) as ext; eauto 3 with slow.
Qed.
Hint Resolve per_nat_bar_type_value_respecting : slow.

Lemma per_nat_bar_term_value_respecting {p} :
  forall (ts : cts(p)), term_value_respecting (per_nat_bar ts).
Proof.
  introv h e ceq.
  unfold per_nat_bar in *; exrepnd; spcast.
  apply h in e; apply h; clear h.
  unfold equality_of_nat_bar in *.
  exrepnd; exists bar0.
  introv ie i; applydup e0 in i; auto.
  unfold equality_of_nat in *; exrepnd.
  exists n; repnd; dands; auto.
  assert (lib_extends lib'0 lib) as ext; eauto 3 with slow.
Qed.
Hint Resolve per_nat_bar_term_value_respecting : slow.

Lemma per_nat_bar_type_transitive {p} :
  forall (ts : cts(p)), type_transitive (per_nat_bar ts).
Proof.
  introv per1 per2.
  unfold type_transitive, per_nat_bar in *; exrepnd.
  dands; auto.

  exists (intersect_bars bar bar0).
  dands.

  - introv i j; simpl in *; exrepnd.
    pose proof (per3 lib2) as q; autodimp q hyp.
    pose proof (q lib'0) as w; simpl in w; autodimp w hyp; eauto 2 with slow.

  - introv i j; simpl in *; exrepnd.
    pose proof (per4 lib1) as q; autodimp q hyp.
    pose proof (q lib'0) as w; simpl in w; autodimp w hyp; eauto 2 with slow.
Qed.
Hint Resolve per_nat_bar_type_transitive : slow.

Lemma ccequivc_ext_mkc_nat_implies {o} :
  forall (lib : @library o) k1 k2,
    ccequivc_ext lib (mkc_nat k1) (mkc_nat k2)
    -> k1 = k2.
Proof.
  introv ceq.
  pose proof (ceq lib) as ceq; autodimp ceq hyp; eauto 3 with slow; simpl in *; spcast.
  apply cequivc_nat_implies_computes_to_valc in ceq.
  apply computes_to_valc_isvalue_eq in ceq; eauto 3 with slow.
  eqconstr ceq; auto.
Qed.

Lemma per_nat_bar_term_transitive {p} :
  forall (ts : cts(p)), term_transitive (per_nat_bar ts).
Proof.
  introv per i j.
  unfold per_nat_bar in per; exrepnd.
  apply per in i; apply per in j; apply per.
  unfold equality_of_nat_bar in *.
  exrepnd.

  clear per per0 per1.

  exists (intersect_bars bar1 bar0).
  unfold equality_of_nat in *.
  introv i j; simpl in *; exrepnd.

  pose proof (i0 lib1) as q; autodimp q hyp; clear i0.
  pose proof (q lib'0) as w; clear q; autodimp w hyp; eauto 2 with slow; simpl in w.

  pose proof (j0 lib2) as q; autodimp q hyp; clear j0.
  pose proof (q lib'0) as z; clear q; autodimp z hyp; eauto 2 with slow; simpl in z.
  exrepnd; spcast.
  computes_to_eqval_ext.
  apply ccequivc_ext_mkc_nat_implies in ceq; subst.
  eexists; dands; spcast; eauto.
Qed.
Hint Resolve per_nat_bar_term_transitive : slow.

Lemma per_nat_type_system {p} :
  forall (ts : cts(p)), type_system (per_nat_bar ts).
Proof.
  intros; unfold type_system; sp.
  - apply per_nat_bar_uniquely_valued.
  - apply per_nat_bar_type_extensionality.
  - apply per_nat_bar_type_symmetric.
  - apply per_nat_bar_type_transitive.
  - apply per_nat_bar_type_value_respecting.
  - apply per_nat_bar_term_symmetric.
  - apply per_nat_bar_term_transitive.
  - apply per_nat_bar_term_value_respecting.
Qed.
Hint Resolve per_nat_type_system : slow.

Lemma ccequivc_ext_preserves_computes_to_valc_nat {o} :
  forall lib (T T' : @CTerm o),
    ccequivc_ext lib T T'
    -> ccomputes_to_valc_ext lib T mkc_Nat
    -> T' ===>(lib) mkc_Nat.
Proof.
  introv ceq comp; eauto 3 with slow.
Qed.

Lemma equality_of_nat_bar_monotone {o} :
  forall {lib' lib : @library o} (ext : lib_extends lib' lib) t1 t2,
    equality_of_nat_bar lib t1 t2
    -> equality_of_nat_bar lib' t1 t2.
Proof.
  introv h; eapply sub_per_equality_of_nat_bar; eauto 3 with slow.
Qed.
Hint Resolve equality_of_nat_bar_monotone : slow.

Lemma per_bar_eq_equality_of_nat_bar_lib_per {o} :
  forall lib (bar : @BarLib o lib),
    (per_bar_eq bar (equality_of_nat_bar_lib_per lib))
    <=2=> (equality_of_nat_bar lib).
Proof.
  introv; simpl; split; intro h; eauto 3 with slow.
  introv br ext; introv; simpl.
  exists (trivial_bar lib'0).
  apply in_ext_ext_implies_all_in_bar_ext_trivial_bar.
  introv y; eauto 3 with slow.
Qed.

Lemma per_nat_bar_implies_close {o} :
  forall (ts : cts(o)) lib T T' eq,
    per_nat_bar (close ts) lib T T' eq
    -> close ts lib T T' eq.
Proof.
  introv per.
  apply CL_bar.
  unfold per_nat_bar in per; exrepnd.
  exists bar (equality_of_nat_bar_lib_per lib).
  dands; eauto 3 with slow.

  - introv br ext; introv; simpl.
    pose proof (per0 _ br _ ext) as per0; simpl in *.
    pose proof (per1 _ br _ ext) as per1; simpl in *.
    apply CL_nat.
    unfold per_nat; dands; auto.

  - eapply eq_term_equals_trans;[eauto|].
    apply eq_term_equals_sym.
    apply per_bar_eq_equality_of_nat_bar_lib_per.
Qed.

Lemma type_equality_respecting_trans1_per_nat_bar_implies {o} :
  forall (ts : cts(o)) lib T T',
    type_system ts
    -> defines_only_universes ts
    -> type_monotone ts
    -> ccomputes_to_valc_ext lib T mkc_Nat
    -> ccomputes_to_valc_ext lib T' mkc_Nat
    -> type_equality_respecting_trans1 (per_nat_bar (close ts)) lib T T'
    -> type_equality_respecting_trans1 (close ts) lib T T'.
Proof.
  introv tsts dou mon inbar1 inbar2 trans h ceq cl.
  apply per_nat_bar_implies_close.
  eapply trans; eauto.
  repndors; subst.

  - apply ccequivc_ext_preserves_computes_to_valc_nat in ceq; auto; spcast.
    dclose_lr; auto.

  - apply ccequivc_ext_preserves_computes_to_valc_nat in ceq; auto; spcast.
    dclose_lr; auto.

  - apply ccequivc_ext_preserves_computes_to_valc_nat in ceq; auto; spcast.
    dclose_lr; auto.

  - apply ccequivc_ext_preserves_computes_to_valc_nat in ceq; auto; spcast.
    dclose_lr; auto.
Qed.
Hint Resolve type_equality_respecting_trans1_per_nat_bar_implies : slow.

Lemma type_equality_respecting_trans2_per_nat_bar_implies {o} :
  forall (ts : cts(o)) lib T T',
    type_system ts
    -> defines_only_universes ts
    -> type_monotone ts
    -> ccomputes_to_valc_ext lib T mkc_Nat
    -> ccomputes_to_valc_ext lib T' mkc_Nat
    -> type_equality_respecting_trans2 (per_nat_bar (close ts)) lib T T'
    -> type_equality_respecting_trans2 (close ts) lib T T'.
Proof.
  introv tsts dou mon inbar1 inbar2 trans h ceq cl.
  apply per_nat_bar_implies_close.
  eapply trans; eauto.
  repndors; subst; dclose_lr; auto.
Qed.
Hint Resolve type_equality_respecting_trans2_per_nat_bar_implies : slow.