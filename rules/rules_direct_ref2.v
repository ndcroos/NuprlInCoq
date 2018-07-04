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


Require Export per_props_qtime_nat.
Require Export per_props_ref.
Require Export rules_ref.


(*
<<
   H |- mk_last_cs(f,d) ∈ QT(ℕ)

     By RefWf2

     H |- f ∈ Free(0)
     H |- d ∈ ℕ
>>

 *)

Definition rule_direct_ref_wf2 {o}
           (lib   : @library o)
           (r d   : NTerm)
           (e1 e2 : NTerm)
           (H     : @bhyps o) :=
  mk_rule
    (mk_baresequent H (mk_conclax (mk_member (mk_read_ref r d) mk_qtnat)))
    [mk_baresequent H (mk_concl (mk_member r (mk_refname 0)) e1),
     mk_baresequent H (mk_concl (mk_member d mk_tnat) e2)]
    [].

Lemma rule_direct_ref_wf2_true {o} :
  forall (lib : SL) (r d e1 e2 : NTerm) (H : @bhyps o),
    rule_true lib (rule_direct_ref_wf2 lib r d e1 e2 H).
Proof.
  unfold rule_direct_ref_wf2, rule_true, closed_type_baresequent, closed_extract_baresequent; simpl.
  intros.
  clear cargs.

  (* We prove the well-formedness of things *)
  destseq; allsimpl.
  dLin_hyp; exrepnd.
  rename Hyp0 into hyp1.
  rename Hyp1 into hyp2.
  destseq; allsimpl; proof_irr; GC.

  assert (@covered o mk_axiom (nh_vars_hyps H)) as cv.
  { dwfseq; tcsp. }
  exists cv.

  (* pick a fresh choice sequence name, and define a constraint based on [hyp1] and [hyp2] *)

  vr_seq_true.
  lsubst_tac.

  rw <- @member_member_iff.
  pose proof (teq_and_member_if_member
                lib' mk_qtnat (mk_read_ref r d) s1 s2 H wT wt ct1 ct2 cT cT0) as q.
  lsubst_tac; autorewrite with slow in *.
  repeat (autodimp q hyp); eauto 2 with slow;[].

  clear dependent s1.
  clear dependent s2.
  introv eqh sim.

  vr_seq_true in hyp1.
  pose proof (hyp1 lib' ext s1 s2 eqh sim) as hyp1; exrepnd.
  vr_seq_true in hyp2.
  pose proof (hyp2 lib' ext s1 s2 eqh sim) as hyp2; exrepnd.

  lsubst_tac.
  apply member_if_inhabited in hyp1.
  apply tequality_mkc_member_implies_sp in hyp0; auto;[].
  apply member_if_inhabited in hyp2.
  apply tequality_mkc_member_implies_sp in hyp3; auto;[].
  autorewrite with slow in *.

  clear hyp1 hyp2.
  apply equality_in_refname in hyp0.
  apply equality_in_tnat in hyp3.

  apply all_in_ex_bar_equality_implies_equality.
  eapply all_in_ex_bar_modus_ponens2;
    [|exact hyp0|exact hyp3]; clear hyp0 hyp3; introv y hyp0 hyp3.
  unfold equality_of_refname in hyp0; exrepnd.
  unfold equality_of_nat in hyp3; exrepnd.
  apply ccomputes_to_valc_ext_implies_ccequivc_ext in hyp1.
  apply ccomputes_to_valc_ext_implies_ccequivc_ext in hyp2.
  apply ccomputes_to_valc_ext_implies_ccequivc_ext in hyp3.
  apply ccomputes_to_valc_ext_implies_ccequivc_ext in hyp4.
  eapply equality_respects_cequivc_left; [apply ccequivc_ext_sym;apply implies_ccequivc_ext_read_ref;eauto|].
  eapply equality_respects_cequivc_right;[apply ccequivc_ext_sym;apply implies_ccequivc_ext_read_ref;eauto|].

  apply equality_in_qtnat.
  apply in_ext_implies_all_in_ex_bar; introv xt.

  pose proof (exists_ccomputes_to_valc_mkc_read_ref_ref lib'1 name k) as w.
  repeat (autodimp w hyp);[eauto 2 with slow|].
  exrepnd; spcast.
  exists (@mkc_nat o n) (@mkc_nat o n).
  dands; spcast; eauto 3 with slow;[].

  apply in_ext_implies_all_in_ex_bar; introv xt'.
  exists n; dands; eauto 3 with slow.
Qed.