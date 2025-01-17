{-# Language QuasiQuotes     #-}
{-# Language TemplateHaskell #-}
{-# Language BangPatterns    #-}
{-# Language ViewPatterns    #-}

module BioInf.ViennaRNA.Bindings.Inline where

import Data.Monoid
import Data.ByteString.Char8 as BS
import qualified Language.C.Inline as C
import Foreign.C.Types
import Foreign.Ptr
import System.IO.Unsafe (unsafePerformIO)
import qualified Data.ByteString.Internal as BI
import Foreign.ForeignPtr.Unsafe


type Energy = Int

C.context (C.baseCtx <> C.bsCtx)
C.include "../C/ViennaRNA/hairpin_loops.h" -- Energy evaluation of hairpin loops for MFE and partition function calculations
C.include "../C/ViennaRNA/interior_loops.h" -- Energy evaluation of interior loops for MFE and partition function calculations.
C.include "../C/ViennaRNA/multibranch_loops.h"
C.include "../C/ViennaRNA/fold.h"
C.include "../C/ViennaRNA/utils.h" -- Needed for "vrna_alloc"
C.include "<stdlib.h>"

-- | Create a default fold compound.

mkFoldCompound :: BS.ByteString -> IO (Ptr ())
mkFoldCompound inp = do
  c <- [C.block| void * {
    const char * seq = $bs-ptr:inp;
    vrna_fold_compound_t * c;
    vrna_md_t md;
    vrna_md_set_default (&md);
    c = vrna_fold_compound (seq, &md, 0);
    return c;
  } |]
  return c

-- c = vrna_fold_compound(seq, NULL, VRNA_OPTION_EVAL_ONLY); TRIED but did neither help
-- | Destroy a given fold compound.

destroyFoldCompound :: Ptr () -> IO ()
destroyFoldCompound cptr = do
  [C.block| void {
    vrna_fold_compound_t * c = $(void * cptr);
    vrna_fold_compound_free (c);
  } |]

-- | Allow operating with a fold compound, hiding the creation.

withFoldCompound :: BS.ByteString -> (Ptr () -> a) -> a
withFoldCompound inp f = unsafePerformIO $ do
  c <- mkFoldCompound inp
  let !x = f c
  destroyFoldCompound c
  return x

-- | Calculate the energy and structure of the given input sequence.

mfe :: BS.ByteString -> (Double, BS.ByteString)
mfe inp = unsafePerformIO $ do
  c <- mkFoldCompound inp
  out <- BI.create (BS.length inp) (\_ -> return ())
  e <- [C.block| float {
    vrna_fold_compound_t * c = $(void *c);
    vrna_mfe (c, $bs-ptr:out);
  } |]
  destroyFoldCompound c
  return (realToFrac e, out)

-- | Calculate the energy of the sequence, assuming that it forms a hairpin.

hairpin :: BS.ByteString -> Energy
hairpin inp = hairpinP inp 0 (fromIntegral $ BS.length inp -1)

-- | Given some sequence, calculate the hairpin energy for the left and right position.

hairpinP :: BS.ByteString -> Int -> Int -> Energy
hairpinP inp i j = unsafePerformIO $ do
  c <- mkFoldCompound inp
  let !e = hairpinCP c i j
  destroyFoldCompound c
  return e

-- | Low-level function that assumes a fold compound and returns the hairpin energy between the two
-- indices.

hairpinCP :: Ptr () -> Int -> Int -> Energy
hairpinCP c (fromIntegral -> i) (fromIntegral -> j) = unsafePerformIO $ do
  e <- [C.block| int {
    vrna_fold_compound_t * c = $(void *c);
    vrna_eval_hp_loop (c, $(int i) , $(int j));
  } |]
  return $ fromIntegral e

-- | Evaluate the free energy contribution of an interior loop with delimiting base pairs (i,j) and (k,l)
intLoopP :: BS.ByteString -> Int -> Int -> Int -> Int -> Energy
intLoopP inp i j k l = unsafePerformIO $ do
  c <- mkFoldCompound inp
  let !e = intLoopCP c i j k l
  destroyFoldCompound c
  return e

-- | Low-level function that assumes a fold compound and returns the interior loop energy between (i,j) and (k,l)
intLoopCP :: Ptr () -> Int -> Int -> Int -> Int -> Energy
intLoopCP c (fromIntegral -> i) (fromIntegral -> j) (fromIntegral -> k) (fromIntegral -> l) = unsafePerformIO $ do
  e <- [C.block| int {
    vrna_fold_compound_t * c = $(void *c);
    vrna_eval_int_loop (c,$(int i), $(int j), $(int k), $(int l));
  } |]
  return $ fromIntegral e

-- | Evaluate Multiloop with closing pair ..
mbLoopP :: BS.ByteString -> Int -> Int -> Energy
mbLoopP inp i j = unsafePerformIO $ do
  c <- mkFoldCompound inp
--  let !len = BS.length $ BS.copy inp
  let !e = mbLoopCP c i j
  destroyFoldCompound c
  return e

mbLoopCP :: Ptr () -> Int -> Int -> Energy
mbLoopCP c (fromIntegral -> i) (fromIntegral -> j) = unsafePerformIO $ do
  e <- [C.block| int {
    vrna_fold_compound_t * c = $(void *c);
    vrna_fold_compound_prepare(c, VRNA_OPTION_MFE);
    int length            =   42;
    int * dmli1 = (int *) vrna_alloc(sizeof(int)*(length + 1));
    int * dmli2 = (int *) vrna_alloc(sizeof(int)*(length + 1));

    /* prefill helper arrays */
    int j;
    for(j = 0; j <= length; j++){
      dmli1[j] = dmli2[j] = INF;
    }

     vrna_E_mb_loop_fast (c, $(int i), $(int j), dmli1, dmli2);
  } |]
  return $ fromIntegral e
