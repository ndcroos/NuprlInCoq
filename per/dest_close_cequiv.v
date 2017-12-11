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


Require Export dest_close_tacs.
Require Export bar_fam.
Require Export per_ceq_bar.


Lemma local_equality_of_cequiv_bar {o} :
  forall {lib} (bar : @BarLib o lib) a b t1 t2,
    all_in_bar_ext bar (fun lib' (x : lib_extends lib' lib) => per_cequiv_eq_bar lib' a b t1 t2)
    -> per_cequiv_eq_bar lib a b t1 t2.
Proof.
  introv alla.
  apply all_in_bar_ext_exists_bar_implies in alla; exrepnd.
  exists (bar_of_bar_fam fbar).
  introv br ext; simpl in *; exrepnd.
  eapply alla0; eauto.
Qed.

(*Lemma per_cequiv_bar_eq {o} :
  forall ts lib (T1 T2 : @CTerm o) eq,
    per_cequiv_bar ts lib T1 T2 eq
    <=>
    {bar : BarLib lib
    , {a, b, c, d : CTerm
    , T1 ==b==>(bar) (mkc_cequiv a b)
    # T2 ==b==>(bar) (mkc_cequiv c d)
    # all_in_bar bar (fun lib => (a ~=~(lib) b <=> c ~=~(lib) d))
    # eq <=2=> (per_cequiv_eq_bar lib a b) }}.
Proof.
  introv; unfold per_cequiv_bar; split; intro h; exrepnd.
  { eexists; eexists; eexists; eexists; eexists; dands; eauto. }
  { eexists; eexists; eexists; eexists; dands; eauto. }
Qed.

Lemma all_in_bar_ext_per_cequiv_bar_eq {o} :
  forall ts lib (bar : @BarLib o lib) (T1 T2 : @CTerm o) eqa,
    all_in_bar_ext bar (fun lib' x => per_cequiv_bar ts lib' T1 T2 (eqa lib' x))
    <=>
    (all_in_bar_ext
       bar
       (fun lib' x =>
          {bar : BarLib lib'
          , {a, b, c, d : CTerm
          , T1 ==b==>(bar) (mkc_cequiv a b)
          # T2 ==b==>(bar) (mkc_cequiv c d)
          # all_in_bar bar (fun lib => (a ~=~(lib) b <=> c ~=~(lib) d))
          # (eqa lib' x) <=2=> (per_cequiv_eq_bar lib' a b) }})).
Proof.
  introv; split; introv h br ext; introv.
  { pose proof (h lib' br lib'0 ext x) as h; simpl in h.
    apply per_cequiv_bar_eq in h; auto. }
  { apply per_cequiv_bar_eq; eapply h; eauto. }
Qed.*)

(*Definition per_cequiv_bar_or {o} ts lib (T T' : @CTerm o) eq :=
  per_cequiv_bar ts lib T T' eq
  {+} per_bar ts lib T T' eq.*)

Lemma per_cequiv_implies_per_bar {o} :
  forall ts lib (T T' : @CTerm o) eq,
    per_cequiv ts lib T T' eq
    -> per_bar (per_cequiv ts) lib T T' eq.
Proof.
  introv per.
  unfold per_cequiv in *; exrepnd.
  exists (trivial_bar lib) (per_cequiv_eq_bar_lib_per lib a b).
  dands; auto.
  - introv br ext; introv; simpl in *.
    exists a b c d; dands; tcsp; eauto 3 with slow.
  - eapply eq_term_equals_trans;[eauto|].
    introv; split; introv h.
    + introv br ext; introv; simpl in *.
      eapply sub_per_cequiv_eq_bar; eauto 3 with slow.
    + pose proof (h lib (lib_extends_refl lib) lib (lib_extends_refl lib) (lib_extends_refl lib)) as h; simpl in *; auto.
Qed.
Hint Resolve per_cequiv_implies_per_bar : slow.

(*Lemma type_extensionality_per_cequiv_bar {o} :
  forall (ts : cts(o)),
    type_extensionality (per_cequiv_bar ts).
Proof.
  introv h e.
  unfold per_cequiv_bar in *; exrepnd.
  exists a b c d; dands; eauto.
  eapply eq_term_equals_trans;[|eauto].
  apply eq_term_equals_sym; auto.
Qed.
Hint Resolve type_extensionality_per_cequiv_bar : slow.

Lemma uniquely_valued_per_cequiv_bar {o} :
  forall (ts : cts(o)), uniquely_valued (per_cequiv_bar ts).
Proof.
  introv h q.
  unfold per_cequiv_bar in *; exrepnd.
  eapply eq_term_equals_trans;[eauto|].
  eapply eq_term_equals_trans;[|apply eq_term_equals_sym;eauto].
  eapply eq_per_cequiv_eq_bar; eapply two_computes_to_valc_ceq_bar_mkc_cequiv; eauto.
Qed.
Hint Resolve uniquely_valued_per_cequiv_bar : slow.*)

Definition per_cequiv_eq_to_lib_per {o}
           (lib : library)
           (T : @CTerm o) : lib-per(lib,o).
Proof.
  exists (fun lib' (x : lib_extends lib' lib) t t' =>
            {a : CTerm , {b : CTerm , T ===>(lib') (mkc_cequiv a b) # per_cequiv_eq_bar lib' a b t t' }}).
  introv x y; introv; simpl; tcsp.
Defined.

Lemma local_per_bar_per_cequiv {o} :
  forall (ts : cts(o)), local_ts (per_bar (per_cequiv ts)).
Proof.
  introv eqiff alla.
  unfold per_bar in *.

  apply all_in_bar_ext_exists_bar_implies in alla; exrepnd.
  exists (bar_of_bar_fam fbar).
  exists (per_cequiv_eq_to_lib_per lib T).
  dands.

  {
    introv br ext; introv; simpl in *; exrepnd.
    pose proof (alla0 _ br _ ext0 x0) as alla0; exrepnd.
    remember (fbar lib1 br lib2 ext0 x0) as bb.
    pose proof (alla0 _ br0 _ ext (lib_extends_trans ext (bar_lib_ext bb lib' br0))) as alla0; simpl in *.
    unfold per_cequiv in *; exrepnd.
    exists a b c d; dands; auto.
    introv; split; intro h; exrepnd; dands; auto.
    - spcast; computes_to_eqval; auto.
    - exists a b; dands; auto.
  }

  {
    eapply eq_term_equals_trans;[eauto|]; clear eqiff.
    introv.
    unfold per_bar_eq; split; introv h; introv br ext; introv; simpl in *; exrepnd.

    - pose proof (alla0 _ br _ ext0 x0) as alla0; exrepnd.
      remember (fbar lib1 br lib2 ext0 x0) as bb.
      pose proof (alla0 _ br0 _ ext (lib_extends_trans ext (bar_lib_ext bb lib' br0))) as alla0; simpl in *.
      pose proof (h _ br _ ext0 x0) as h; simpl in *.
      apply alla1 in h.
      pose proof (h _ br0 _ ext (lib_extends_trans ext (bar_lib_ext bb lib' br0))) as h; simpl in *.
      unfold per_cequiv in alla0; exrepnd.
      apply alla0 in h.
      exists a b; dands; auto.

    - pose proof (alla0 _ br _ ext x) as alla0; exrepnd.
      apply alla1; clear alla1.
      introv br' ext'; introv.
      pose proof (alla0 _ br' _ ext' x0) as alla0; simpl in *.
      pose proof (h lib'1) as h; simpl in h; autodimp h hyp;
        [eexists; eexists; eexists; eexists; eexists; eauto|].
      pose proof (h lib'2 ext') as h; simpl in *; autodimp h hyp; eauto 3 with slow;[].
      exrepnd.
      unfold per_cequiv in *; exrepnd.
      spcast; computes_to_eqval; auto.
      apply alla0; auto.
  }
Qed.


(* ====== dest lemmas ====== *)

Lemma dest_close_per_cequiv_l {p} :
  forall (ts : cts(p)) lib T A B T' eq,
    type_system ts
    -> defines_only_universes ts
    -> computes_to_valc lib T (mkc_cequiv A B)
    -> close ts lib T T' eq
    -> per_bar (per_cequiv (close ts)) lib T T' eq.
Proof.
  introv tysys dou comp cl.
  close_cases (induction cl using @close_ind') Case; subst; try close_diff_all; auto; eauto 3 with slow.
  eapply local_per_bar_per_cequiv; eauto; eauto 3 with slow.
  introv br ext; introv; eapply reca; eauto 3 with slow.
Qed.

Lemma dest_close_per_cequiv_r {p} :
  forall (ts : cts(p)) lib T A B T' eq,
    type_system ts
    -> defines_only_universes ts
    -> computes_to_valc lib T' (mkc_cequiv A B)
    -> close ts lib T T' eq
    -> per_bar (per_cequiv (close ts)) lib T T' eq.
Proof.
  introv tysys dou comp cl.
  close_cases (induction cl using @close_ind') Case; subst; try close_diff_all; auto; eauto 3 with slow.
  eapply local_per_bar_per_cequiv; eauto; eauto 3 with slow.
  introv br ext; introv; eapply reca; eauto 3 with slow.
Qed.

Lemma dest_close_per_cequiv_l_ceq {p} :
  forall (ts : cts(p)) lib (bar : BarLib lib) T A B T' eq,
    type_system ts
    -> defines_only_universes ts
    -> computes_to_valc_ceq_bar bar T (mkc_cequiv A B)
    -> close ts lib T T' eq
    -> per_bar (per_cequiv (close ts)) lib T T' eq.
Proof.
  introv tysys dou comp cl.
  close_cases (induction cl using @close_ind') Case; subst; try close_diff_all; auto; eauto 3 with slow.
  eapply local_per_bar_per_cequiv; eauto; eauto 3 with slow.
  introv br ext; introv; apply (reca lib' br lib'0 ext x (raise_bar bar x)); eauto 3 with slow.
Qed.

Lemma dest_close_per_cequiv_r_ceq {p} :
  forall (ts : cts(p)) lib (bar : BarLib lib) T A B T' eq,
    type_system ts
    -> defines_only_universes ts
    -> computes_to_valc_ceq_bar bar T' (mkc_cequiv A B)
    -> close ts lib T T' eq
    -> per_bar (per_cequiv (close ts)) lib T T' eq.
Proof.
  introv tysys dou comp cl.
  close_cases (induction cl using @close_ind') Case; subst; try close_diff_all; auto; eauto 3 with slow.
  eapply local_per_bar_per_cequiv; eauto; eauto 3 with slow.
  introv br ext; introv; apply (reca lib' br lib'0 ext x (raise_bar bar x)); eauto 3 with slow.
Qed.
