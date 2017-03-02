(*

  Copyright 2014 Cornell University
  Copyright 2015 Cornell University
  Copyright 2016 Cornell University

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


Require Export nuprl_props.
Require Export choice.
Require Export cvterm.


Lemma equality_in_uni_as_tequalityi {o} :
  forall lib i (A B : @CTerm o),
    equality lib A B (mkc_uni i) = tequalityi lib i A B.
Proof.
  auto.
Qed.

Lemma equality_in_uni {p} :
  forall lib a b i,
    @equality p lib a b (mkc_uni i)
    -> tequality lib a b.
Proof.
  unfold tequality, equality, nuprl; introv e; exrepnd.

  inversion e1; subst; try not_univ.
  duniv j h.
  induction j; allsimpl; sp.
  computes_to_value_isvalue.
  match goal with
  | [ H : _ <=2=> _ |- _ ] => apply H in e0; clear H
  end.
  unfold univi_eq, extts in e0; exrepnd.
  exists eqa.
  eapply Nuprli_implies_Nuprl; split; eauto.
Qed.

Lemma tequalityi_implies_tequality {o} :
  forall lib i (A B : @CTerm o),
    tequalityi lib i A B -> tequality lib A B.
Proof.
  introv n.
  unfold tequalityi in n.
  apply equality_in_uni in n; auto.
Qed.
Hint Resolve tequalityi_implies_tequality : slow.

Lemma member_in_uni {p} :
  forall lib a i, @member p lib a (mkc_uni i) -> type lib a.
Proof.
  unfold member; introv e.
  apply equality_in_uni in e; eauto 2 with slow.
Qed.

Lemma equality_Nuprli {p} :
  forall lib (A B C : @CTerm p) i eq,
    equality lib A B (mkc_uni i)
    -> Nuprli lib i A C eq
    -> Nuprli lib i A B eq.
Proof.
  introv e n.
  destruct n as [n1 n2].
  split; auto.
  clear dependent C.

  unfold equality, nuprl in e; exrepnd.
  inversion e1; try not_univ.
  duniv j h.
  allrw @univi_exists_iff; exrepnd.
  computes_to_value_isvalue; GC.
  apply h0 in e0.
  unfold univi_eq, extts in e0; exrepnd.
  allfold (@nuprli p lib j0).

  pose proof (nuprli_uniquely_valued lib j0 j0 A eqa eq) as k.
  repeat (autodimp k hyp).
  eapply nuprli_ext; eauto.
Qed.

Lemma equality_uprli {p} :
  forall lib (A B : @CTerm p) i eq,
    equality lib A B (mkc_uni i)
    -> nuprli lib i A eq
    -> nuprli lib i B eq.
Proof.
  introv e n.

  unfold equality, nuprl in e; exrepnd.
  inversion e1; try not_univ.
  duniv j h.
  allrw @univi_exists_iff; exrepnd.
  computes_to_value_isvalue; GC.
  apply h0 in e0.
  unfold univi_eq, extts in e0; exrepnd.
  allfold (@nuprli p lib j0).

  pose proof (nuprli_uniquely_valued lib j0 j0 A eqa eq) as k.
  repeat (autodimp k hyp).
  eapply nuprli_ext; eauto.
Qed.

(*
Lemma mkc_uni_in_nuprl {p} :
  forall lib (i : nat),
    nuprl
      lib
      (mkc_uni i)
      (mkc_uni i)
      (univi_eq lib (univi lib i)).
Proof.
  introv.
  apply CL_init.
  exists (S i); simpl.
  left; sp; spcast; apply computes_to_valc_refl; sp.
Qed.


Lemma nuprl_mkc_uni {p} :
  forall lib (i : nat),
    {eq : per(p) , nuprl lib (mkc_uni i) (mkc_uni i) eq}.
Proof.
  intros.
  exists (fun A A' => {eqa : per(p) , close lib (univi lib i) A A' eqa}).
  apply mkc_uni_in_nuprl.
Qed.
*)

Lemma mkc_uni_in_uni {o} :
  forall lib j, @univ o lib (mkc_uni j) (univi_eq lib (univi lib j)).
Proof.
  introv; exists (S j); apply univi_mkc_uni.
Qed.
Hint Resolve mkc_uni_in_uni : slow.

Lemma mkc_uni_in_nuprl {o} :
  forall lib i, @nuprl o lib (mkc_uni i) (univi_eq lib (univi lib i)).
Proof.
  introv; apply CL_init; eauto 2 with slow.
Qed.
Hint Resolve mkc_uni_in_nuprl : slow.

Lemma tequality_mkc_uni {p} :
  forall lib (i : nat), @tequality p lib (mkc_uni i) (mkc_uni i).
Proof.
  introv.
  exists (univi_eq lib (univi lib i)).
  split; eauto 3 with slow.
Qed.
Hint Resolve tequality_mkc_uni : slow.

Lemma mkc_uni_in_nuprli {o} :
  forall lib i j, i < j -> @nuprli o lib j (mkc_uni i) (univi_eq lib (univi lib i)).
Proof.
  introv ltij.
  apply CL_init.
  apply univi_exists_iff.
  exists i; dands; spcast; tcsp; try (apply computes_to_valc_refl; eauto 3 with slow).
Qed.
Hint Resolve mkc_uni_in_nuprli : slow.

Lemma uni_in_uni {o} :
  forall lib i j, i < j -> @member o lib (mkc_uni i) (mkc_uni j).
Proof.
  introv h.
  unfold member, equality, nuprl.
  exists (univi_eq lib (univi lib j)).
  dands; eauto 3 with slow.

  exists (univi_eq lib (univi lib i)); split; fold (nuprli lib j); eauto 2 with slow.
Qed.

Lemma typable_in_higher_univ_lt {o} :
  forall lib i j (T : @CTerm o) eq,
    i <= j
    -> nuprli lib i T eq
    -> nuprli lib j T eq.
Proof.
  introv ltij n.
  pose proof (typable_in_higher_univ lib i T eq n (j - i)) as q.
  rewrite minus_plus_n in q; auto.
Qed.

Lemma cumulativity {o} :
  forall lib i j (A B : @CTerm o),
    i < j
    -> equality lib A B (mkc_uni i)
    -> equality lib A B (mkc_uni j).
Proof.
  introv h equ.
  unfold member, equality, nuprl in *; destruct equ as [eqa equ]; repnd.
  exists (univi_eq lib (univi lib j)).
  dands; eauto 2 with slow.

  eapply nuprl_uniquely_valued in equ0;[|apply mkc_uni_in_nuprl].
  apply equ0 in equ.
  unfold univi_eq, extts in equ; exrepnd.
  clear equ0.

  fold (nuprli lib i) in *.
  fold (nuprli lib j) in *.

  exists eqa0; split; apply (typable_in_higher_univ_lt _ i j); auto; omega.
Qed.