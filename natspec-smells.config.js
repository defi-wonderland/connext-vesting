/**
 * List of supported options: https://github.com/defi-wonderland/natspec-smells?tab=readme-ov-file#options
 */

/** @type {import('@defi-wonderland/natspec-smells').Config} */
module.exports = {
  include: 'solidity',
  exclude: ['solidity/(test|scripts)/**/*.sol'],
  constructorNatspec: true,
  enforceInheritdoc: false,
};
