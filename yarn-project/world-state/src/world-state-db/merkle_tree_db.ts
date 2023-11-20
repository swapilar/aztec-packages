import { MerkleTreeOperations } from './merkle_tree_db_operations.js';

/**
 * Adds a last boolean flag in each function on the type.
 */
type WithIncludeUncommitted<F> = F extends (...args: [...infer Rest]) => infer Return
  ? (...args: [...Rest, boolean]) => Return
  : F;

/**
 * Defines the names of the setters on Merkle Trees.
 */
type MerkleTreeSetters = 'appendLeaves' | 'updateLeaf' | 'commit' | 'rollback' | 'handleL2Block' | 'batchInsert';

/**
 * Defines the interface for operations on a set of Merkle Trees configuring whether to return committed or uncommitted data.
 */
export type MerkleTreeDb = {
  [Property in keyof MerkleTreeOperations as Exclude<Property, MerkleTreeSetters>]: WithIncludeUncommitted<
    MerkleTreeOperations[Property]
  >;
} & Pick<MerkleTreeOperations, MerkleTreeSetters>;
