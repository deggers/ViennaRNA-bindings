
#include "../C/ViennaRNA/hairpin_loops.h"

#include "../C/ViennaRNA/interior_loops.h"

#include "../C/ViennaRNA/multibranch_loops.h"

#include "../C/ViennaRNA/fold.h"

#include "../C/ViennaRNA/utils.h"

#include <stdlib.h>

void * inline_c_BioInf_ViennaRNA_Bindings_Inline_0_1e3ca529b6a7f932c3300278b5ce75c869288b45(char * inp_inline_c_0) {

    const char * seq = inp_inline_c_0;
    vrna_fold_compound_t * c;
    vrna_md_t md;
    vrna_md_set_default (&md);
    c = vrna_fold_compound (seq, &md, 0);
    return c;
  
}


void inline_c_BioInf_ViennaRNA_Bindings_Inline_1_e9f91246b873f63a828b7c8fd63953e19fa673d5(void * cptr_inline_c_0) {

    vrna_fold_compound_t * c = cptr_inline_c_0;
    vrna_fold_compound_free (c);
  
}


float inline_c_BioInf_ViennaRNA_Bindings_Inline_2_71d180885dabd62881059351f079b3b85dc5a160(void * c_inline_c_0, char * out_inline_c_1) {

    vrna_fold_compound_t * c = c_inline_c_0;
    vrna_mfe (c, out_inline_c_1);
  
}


int inline_c_BioInf_ViennaRNA_Bindings_Inline_3_8f824d90f5f3dc6f1c5df2d678598c958988547e(void * c_inline_c_0, int i_inline_c_1, int j_inline_c_2) {

    vrna_fold_compound_t * c = c_inline_c_0;
    vrna_eval_hp_loop (c, i_inline_c_1 , j_inline_c_2);
  
}


int inline_c_BioInf_ViennaRNA_Bindings_Inline_4_468218ae30e535aae5340e7c4609c531245f42af(void * c_inline_c_0, int i_inline_c_1, int j_inline_c_2, int k_inline_c_3, int l_inline_c_4) {

    vrna_fold_compound_t * c = c_inline_c_0;
    vrna_eval_int_loop (c,i_inline_c_1, j_inline_c_2, k_inline_c_3, l_inline_c_4);
  
}


int inline_c_BioInf_ViennaRNA_Bindings_Inline_5_3fa575edc034700c93e8d87daab73ec38c8fed47(void * c_inline_c_0, int i_inline_c_1, int j_inline_c_2) {

    vrna_fold_compound_t * c = c_inline_c_0;
    vrna_fold_compound_prepare(c, VRNA_OPTION_MFE);
    int length            =   42;
    int * dmli1 = (int *) vrna_alloc(sizeof(int)*(length + 1));
    int * dmli2 = (int *) vrna_alloc(sizeof(int)*(length + 1));

    
    int j;
    for(j = 0; j <= length; j++){
      dmli1[j] = dmli2[j] = INF;
    }

     vrna_E_mb_loop_fast (c, i_inline_c_1, j_inline_c_2, dmli1, dmli2);
  
}

