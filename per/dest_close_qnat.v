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

  Authors: Abhishek Anand & Vincent Rahli

*)


Require Export dest_close_tacs.
Require Export bar_fam.
Require Export local.


Lemma local_equality_of_qnat_bar {o} :
  forall {lib : SL} (bar : @BarLib o lib) t1 t2,
    all_in_bar_ext bar (fun lib' (x : lib_extends lib' lib) => equality_of_qnat_bar lib' t1 t2)
    -> equality_of_qnat_bar lib t1 t2.
Proof.
  introv alla.
  apply all_in_bar_ext_exists_bar_implies in alla; exrepnd.
  exists (bar_of_bar_fam fbar).
  introv br ext; simpl in *; exrepnd.
  eapply alla0; eauto.
Qed.
Hint Resolve local_equality_of_qnat_bar : slow.

Lemma per_bar_eq_equality_of_qnat_bar_implies {o} :
  forall {lib : SL} (bar : @BarLib o lib) t1 t2,
    per_bar_eq bar (equality_of_qnat_bar_lib_per lib) t1 t2
    -> equality_of_qnat_bar lib t1 t2.
Proof.
  introv alla.
  unfold per_bar_eq in alla.
  apply all_in_bar_ext_exists_bar_implies in alla; exrepnd; simpl in *.
  apply all_in_bar_ext_exists_fbar_implies in alla0; exrepnd; simpl in *.

  exists (bar_of_bar_fam_fam ffbar).
  introv br ext; simpl in *; exrepnd.
  pose proof (alla1 _ br _ ext0 x _ br' _ ext' x') as alla0; simpl in *.
  eapply alla0; eauto.
Qed.
Hint Resolve per_bar_eq_equality_of_qnat_bar_implies : slow.

Lemma all_in_bar_ext_equal_equality_of_qnat_bar_implies_per_bar_eq_implies_equality_of_qnat_bar {o} :
  forall (lib : SL) (bar : @BarLib o lib) (eqa : lib-per(lib,o)),
    all_in_bar_ext bar (fun lib' x => (eqa lib' x) <=2=> (equality_of_qnat_bar lib'))
    -> (per_bar_eq bar eqa) <=2=> (equality_of_qnat_bar lib).
Proof.
  introv alla; introv; split; introv h.

  - pose proof (all_in_bar_ext_eq_term_equals_preserves_per_bar_eq
                  _ bar eqa (equality_of_qnat_bar_lib_per lib) t1 t2 alla h) as q.
    eauto 3 with slow.

  - introv br ext; introv.
    exists (trivial_bar lib'0).
    introv br' ext'; introv; simpl in *.
    apply (alla _ br _ (lib_extends_trans x0 ext) (lib_extends_trans x0 x)).
    eapply sub_per_equality_of_qnat_bar;[|eauto]; eauto 3 with slow.
Qed.
Hint Resolve all_in_bar_ext_equal_equality_of_qnat_bar_implies_per_bar_eq_implies_equality_of_qnat_bar : slow.

Lemma local_per_qnat_bar {o} :
  forall (ts : cts(o)), local_ts (per_qnat_bar ts).
Proof.
  introv eqiff alla.
  unfold per_qnat_bar in *.
  apply all_in_bar_ext_and_implies in alla; repnd.
  apply all_in_bar_ext_exists_bar_implies in alla0.
  exrepnd.
  dands.

  {
    exists (bar_of_bar_fam fbar).
    dands; introv br ext; simpl in *; exrepnd; eapply alla1; eauto.
  }

  eapply eq_term_equals_trans;[eauto|]; eauto 3 with slow.
Qed.

Lemma per_qnat_implies_per_qnat_bar {o} :
  forall ts lib (T T' : @CTerm o) eq,
    per_qnat ts lib T T' eq
    -> per_qnat_bar ts lib T T' eq.
Proof.
  introv per.
  unfold per_qnat in per; repnd.
  unfold per_qnat_bar.
  dands; auto.
  exists (trivial_bar lib).
  dands; eauto 3 with slow.
Qed.
Hint Resolve per_qnat_implies_per_qnat_bar : slow.


(* ====== dest lemmas ====== *)

Lemma dest_close_per_qnat_l {p} :
  forall (ts : cts(p)) lib T T' eq,
    type_system ts
    -> defines_only_universes ts
    -> ccomputes_to_valc_ext lib T mkc_qnat
    -> close ts lib T T' eq
    -> per_qnat_bar (close ts) lib T T' eq.
Proof.
  introv tysys dou comp cl.
  close_cases (induction cl using @close_ind') Case; subst; try close_diff_all; auto; eauto 2 with slow.
  eapply local_per_qnat_bar; eauto.
  introv br ext; introv; apply (reca lib' br lib'0 ext x); eauto 3 with slow.
Qed.

Lemma dest_close_per_qnat_r {p} :
  forall (ts : cts(p)) lib T T' eq,
    type_system ts
    -> defines_only_universes ts
    -> ccomputes_to_valc_ext lib T' mkc_qnat
    -> close ts lib T T' eq
    -> per_qnat_bar (close ts) lib T T' eq.
Proof.
  introv tysys dou comp cl.
  close_cases (induction cl using @close_ind') Case; subst; try close_diff_all; auto; eauto 2 with slow.
  eapply local_per_qnat_bar; eauto.
  introv br ext; introv; apply (reca lib' br lib'0 ext x); eauto 3 with slow.
Qed.